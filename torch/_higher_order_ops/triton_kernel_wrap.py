from typing import Any, Dict
from torch._ops import HigherOrderOperator
from torch._C import DispatchKey

# Used for wrapping a Triton Kernel
class TritonKernelWrapperMutation(HigherOrderOperator):
    def __init__(self):
        super().__init__("triton_kernel_wrapper_mutation")

    def __call__(self, *, kernel, grid, kwargs):
        kernel[grid](**kwargs)


triton_kernel_wrapper_mutation = TritonKernelWrapperMutation()

def grid_fn_code(name, configs, grids):
    assert len(grids) == len(configs)
    fn_name = f"grid_wrapper_for_{name}"
    grid_fn_str = f"def {fn_name}(meta):"
    for grid, config in zip(grids, configs):
        guards = [f"meta['{name}'] == {val}" for name, val in config.kwargs.items()]
        guards = " and ".join(guards)
        grid_fn_str += f"\n\tif {guards}: return {grid}"
    return fn_name, grid_fn_str

