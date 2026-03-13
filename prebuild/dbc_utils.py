"""Shared DBC file reading utilities for ForgeLoot PoE Orbs prebuild scripts.

All prebuild scripts that read WDBC files should import from here
to avoid duplicating the binary parsing logic.
"""

import os
import struct
import sys


def read_dbc(path):
    """Read a WDBC file. Returns (header, records, string_block).

    header: dict with record_count, field_count, record_size, string_size
    records: list of raw bytes per record
    string_block: bytes
    """
    with open(path, 'rb') as f:
        data = f.read()

    magic, record_count, field_count, record_size, string_size = struct.unpack_from(
        '<4sIIII', data, 0)
    if magic != b'WDBC':
        raise ValueError("Invalid DBC magic in %s: %s" % (path, magic))

    header = {
        'record_count': record_count,
        'field_count': field_count,
        'record_size': record_size,
        'string_size': string_size,
    }

    data_start = 20
    records = []
    for i in range(record_count):
        offset = data_start + i * record_size
        records.append(data[offset:offset + record_size])

    string_block = data[data_start + record_count * record_size:]
    return header, records, string_block


def get_uint32(record, field_index):
    """Read a uint32 field from a DBC record by field index."""
    return struct.unpack_from('<I', record, field_index * 4)[0]


def get_int32(record, field_index):
    """Read a signed int32 field from a DBC record by field index."""
    return struct.unpack_from('<i', record, field_index * 4)[0]


def get_string(record, field_index, string_block):
    """Read a string from a DBC record (field is offset into string block)."""
    offset = get_uint32(record, field_index)
    if offset == 0 or offset >= len(string_block):
        return ''
    end = string_block.index(b'\x00', offset)
    return string_block[offset:end].decode('utf-8', errors='replace')


def resolve_dbc_dir(project_config):
    """Find the DBC directory from a project config dict.

    Checks setup.game_data_source/dbc and setup.runtime_dir/dbc.
    Returns the path string, or exits with error if not found.
    """
    setup = project_config.get('setup', {})
    for key in ['game_data_source', 'runtime_dir']:
        candidate = setup.get(key, '')
        if candidate:
            path = os.path.join(candidate, 'dbc')
            if os.path.isdir(path):
                return path

    print("ERROR: Could not find DBC directory")
    print("  Set setup.game_data_source or setup.runtime_dir in project.yaml")
    sys.exit(1)
