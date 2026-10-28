import sys
from pathlib import Path

import svtb

# fault and magma resolve as top-level modules from svtb's installed location.
sys.path.insert(0, str(Path(svtb.__file__).resolve().parent))
