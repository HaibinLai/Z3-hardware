# Z3 Hardware Numerical Verification

Reproducible numerical verification of hardware operators using real RTL, exact arithmetic, Z3 and native RTL simulation.

The current study repairs the `DSP_SEED` backend of Vortex `VX_rtu_recip`: gradual-underflow output packing, exponent-wrap prevention, and nearest-even rounding of subnormal results. The lookup/iteration core and normal-range results are preserved.

Source pin: Vortex `127178d6375c3cb525e2c8af0c77b5f2d52ed93e`.

The verification scripts use complete finite-domain instantiation over 1024 lookup bins (8192 FP32 fractions per bin), with explicit coverage, attainable extrema, RTL-transition refinement checks, and independent native simulation. This is exhaustive finite verification, not sampled maxima or a claim that all nonlinear queries were solved by Optimize.

The code, exact result summaries and English accuracy figures are being organized in the reciprocal experiment directory. Large generated tables and build products are kept outside Git history and can be regenerated with the scripts.
