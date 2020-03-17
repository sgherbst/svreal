from pathlib import Path

PACK_DIR = Path(__file__).resolve().parent

def get_svreal_header():
    return PACK_DIR / 'svreal.sv'