#!/usr/bin/env python3
"""
Extract the Audit Log-scoped OpenAPI spec from the full commercetools API spec.

Downloads the commercetools Composable Commerce API description published in
wso2/api-specs (~3 MB, 299 paths) and writes the trimmed spec the
`ballerinax/commercetools.auditlog` connector is generated from:

  openapi.yaml    — 1 path, 2 operations, components pruned to the transitive
                    $ref closure of those operations

The trimming rules:

  paths       only the operations listed in KEEP, copied verbatim; the
              path-level keys (description, parameters, x-annotation-*) are
              kept, every other method on the path is dropped
  info        upstream info, unchanged
  servers     upstream servers, unchanged
  components  the transitive $ref closure of the kept operations, plus the
              security schemes those operations name in `security`

The closure deliberately does NOT follow `discriminator.mapping` targets. Those
mappings are name-to-schema hints, not $refs, and following them would drag in
most of the upstream schemas. Instead, every mapping whose target did not make
it into the subset is removed, and a discriminator left with no mapping is
dropped, so the output stays self-contained.

The output is the *input* to the remaining sanitations in docs/spec/sanitations.md
(summaries, the bogus `//` required entry, the server URL and the token URL),
which are applied on top of it in docs/spec/openapi.yaml.

Paths resolve relative to this file, so it can be run from anywhere. The source
spec is cached beside the script and re-downloaded only when it is missing:

    python3 docs/resources/script.py
"""

from __future__ import annotations

import ssl
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path
from typing import Iterable

try:
    import yaml
except ImportError:
    sys.stderr.write("PyYAML is required: pip install pyyaml\n")
    sys.exit(1)

try:
    from yaml import CSafeLoader as YamlLoader, CSafeDumper as YamlDumper
except ImportError:
    from yaml import SafeLoader as YamlLoader, SafeDumper as YamlDumper


REPO_ROOT = Path(__file__).resolve().parent
SOURCE = REPO_ROOT / "commercetools-api-openapi.yaml"
# The full commercetools Composable Commerce API description as published in
# wso2/api-specs, versioned with the rest of the specs this org generates
# connectors from, so the source a connector was built from stays pinned.
SOURCE_URL = (
    "https://raw.githubusercontent.com/wso2/api-specs/"
    "main/openapi/commercetools/api/v1/openapi.yaml"
)
OUT = REPO_ROOT / "openapi.yaml"

# The operations this connector exposes, as (path, method). They match the
# surface of the connector's previous release.
KEEP = (
    ("/{projectKey}", "get"),
    ("/{projectKey}", "post"),
)

# Emitted in this order, and only when non-empty.
COMPONENT_SECTIONS = (
    "schemas",
    "responses",
    "parameters",
    "examples",
    "requestBodies",
    "headers",
    "securitySchemes",
    "links",
    "callbacks",
)

OPERATION_KEYS = frozenset(
    ("get", "put", "post", "delete", "options", "head", "patch", "trace")
)

REF_PREFIX = "#/components/"


def _ssl_context() -> ssl.SSLContext:
    """Verify against certifi's CA bundle when it is installed.

    The python.org macOS builds ship without a usable trust store until
    `Install Certificates.command` has been run, and fail every HTTPS fetch with
    CERTIFICATE_VERIFY_FAILED. certifi is present far more often than that
    command has been run."""
    try:
        import certifi
    except ImportError:
        return ssl.create_default_context()
    return ssl.create_default_context(cafile=certifi.where())


def download_source(target: Path) -> None:
    print(f"Downloading {SOURCE_URL} ...", flush=True)
    try:
        with urllib.request.urlopen(SOURCE_URL, context=_ssl_context()) as response:
            payload = response.read()
    except urllib.error.HTTPError as exc:
        raise SystemExit(
            f"Download failed: HTTP {exc.code} for {SOURCE_URL}\n"
            "If the spec has not landed in wso2/api-specs yet, drop a local copy "
            f"at {target.name} beside this script."
        ) from exc
    except urllib.error.URLError as exc:
        raise SystemExit(f"Download failed: {exc.reason} for {SOURCE_URL}") from exc
    target.write_bytes(payload)
    print(f"  wrote {target.name} ({target.stat().st_size:,} bytes)")


def load_source(path: Path) -> dict:
    with path.open(encoding="utf-8") as fh:
        return yaml.load(fh, Loader=YamlLoader)


def collect_refs(node) -> Iterable[str]:
    """Yield every `$ref` string inside `node`, skipping `discriminator` subtrees."""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "$ref" and isinstance(value, str):
                yield value
            elif key == "discriminator":
                continue
            else:
                yield from collect_refs(value)
    elif isinstance(node, list):
        for item in node:
            yield from collect_refs(item)


def collect_security_schemes(paths: dict) -> set[str]:
    """Collect the security scheme names the kept operations require."""
    used: set[str] = set()
    for path_item in paths.values():
        for key, op in path_item.items():
            if key in OPERATION_KEYS and isinstance(op, dict):
                for requirement in op.get("security") or []:
                    used.update(requirement)
    return used


def walk_ref_closure(seed_node, components: dict) -> dict[str, set[str]]:
    """Transitively resolve every `$ref` reachable from `seed_node`."""
    kept: dict[str, set[str]] = {section: set() for section in COMPONENT_SECTIONS}
    queue = list(collect_refs(seed_node))
    while queue:
        ref = queue.pop()
        if not ref.startswith(REF_PREFIX):
            continue
        section, _, name = ref[len(REF_PREFIX):].partition("/")
        if section not in kept or not name or name in kept[section]:
            continue
        kept[section].add(name)
        component = components.get(section, {}).get(name)
        if component is None:
            # Dangling upstream ref — record but don't crash.
            continue
        queue.extend(collect_refs(component))
    return kept


def subset_components(components: dict, kept: dict[str, set[str]]) -> dict:
    """Project `components` down to `kept`, preserving upstream key order."""
    out: dict = {}
    for section in COMPONENT_SECTIONS:
        names = kept.get(section) or set()
        if not names:
            continue
        source = components.get(section) or {}
        subset = {name: source[name] for name in source if name in names}
        if subset:
            out[section] = subset
    return out


def prune_discriminators(node, schemas: set[str]) -> int:
    """Drop discriminator mappings whose target schema is not in `schemas`.

    A discriminator left with no mapping is removed. Returns the number of
    mapping entries dropped."""
    dropped = 0
    if isinstance(node, dict):
        discriminator = node.get("discriminator")
        if isinstance(discriminator, dict) and isinstance(discriminator.get("mapping"), dict):
            mapping = discriminator["mapping"]
            surviving = {
                key: target
                for key, target in mapping.items()
                if target.startswith(REF_PREFIX + "schemas/")
                and target[len(REF_PREFIX + "schemas/"):] in schemas
            }
            dropped += len(mapping) - len(surviving)
            if surviving:
                discriminator["mapping"] = surviving
            else:
                del node["discriminator"]
        for value in node.values():
            dropped += prune_discriminators(value, schemas)
    elif isinstance(node, list):
        for item in node:
            dropped += prune_discriminators(item, schemas)
    return dropped


def count_ops(paths: dict) -> int:
    return sum(
        sum(1 for key in item if key in OPERATION_KEYS)
        for item in paths.values()
        if isinstance(item, dict)
    )


def select_paths(source_paths: dict) -> dict:
    """Copy the KEEP operations, with their path-level keys, in upstream order."""
    wanted: dict[str, set[str]] = {}
    for path, method in KEEP:
        wanted.setdefault(path, set()).add(method)

    selected: dict = {}
    for path, item in source_paths.items():
        methods = wanted.get(path)
        if not methods:
            continue
        selected[path] = {
            key: value
            for key, value in item.items()
            if key not in OPERATION_KEYS or key in methods
        }

    missing = [
        f"{method.upper()} {path}"
        for path, method in KEEP
        if method not in selected.get(path, {})
    ]
    if missing:
        raise SystemExit(f"Not in the source spec: {', '.join(missing)} — is the source spec correct?")
    return selected


def build_output(source_doc: dict) -> tuple[dict, int]:
    selected_paths = select_paths(source_doc["paths"])

    components = source_doc.get("components") or {}
    kept = walk_ref_closure(selected_paths, components)
    kept["securitySchemes"].update(collect_security_schemes(selected_paths))
    pruned_components = subset_components(components, kept)

    out: dict = {"openapi": source_doc["openapi"], "info": source_doc.get("info") or {}}
    if "servers" in source_doc:
        out["servers"] = source_doc["servers"]
    out["paths"] = selected_paths
    out["components"] = pruned_components

    dropped = prune_discriminators(out, set(pruned_components.get("schemas") or {}))
    return out, dropped


def write_yaml(target: Path, doc: dict) -> None:
    class Dumper(YamlDumper):
        # The spec reuses identical sub-documents; anchors/aliases would be
        # valid YAML but most OpenAPI tooling chokes on them.
        def ignore_aliases(self, data):
            return True

    with target.open("w", encoding="utf-8") as fh:
        yaml.dump(
            doc,
            fh,
            Dumper=Dumper,
            sort_keys=False,
            allow_unicode=True,
            width=120,
            default_flow_style=False,
        )


def main() -> int:
    if not SOURCE.exists():
        download_source(SOURCE)

    t0 = time.monotonic()
    print(f"Loading {SOURCE.name} ({SOURCE.stat().st_size:,} bytes) ...", flush=True)
    source_doc = load_source(SOURCE)
    print(f"  {len(source_doc['paths']):,} paths, "
          f"{len(source_doc.get('components', {}).get('schemas', {})):,} schemas "
          f"({time.monotonic() - t0:.1f}s)")

    print(f"Selecting {', '.join(f'{m.upper()} {p}' for p, m in KEEP)} ...")
    doc, dropped = build_output(source_doc)
    print(f"  {len(doc['paths']):,} paths, {count_ops(doc['paths']):,} operations")
    for section, entries in doc["components"].items():
        print(f"  {section:<16} {len(entries):,}")
    print(f"  dropped {dropped:,} discriminator mappings to schemas outside the subset")

    write_yaml(OUT, doc)
    print(f"\nWrote {OUT.name} ({OUT.stat().st_size:,} bytes) in {time.monotonic() - t0:.1f}s")
    return 0


if __name__ == "__main__":
    sys.exit(main())
