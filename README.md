# PyTorch–Vortex–Ventus 浮点精度验证原型

这是一个可重跑的研究原型：对照 PyTorch CPU/CUDA 的浮点结果、Z3 的局部数值界，以及开源 GPU 的数值运算源码。原始实验在 Ubuntu 24.04、Python 3.12 的 `eightsocket` 节点完成；源码提交和软件版本记录在 `results/environment.json`。仓库不包含虚拟环境、编译产物或第三方 GPU 源码。

## 已验证的结论

1. **PyTorch CPU 交叉熵梯度反例。** 在 PyTorch `2.15.0+cpu` 中，输入 logits `[0,-18]`、目标类别 0、FP32 时，`F.cross_entropy` 的损失与目标梯度均为 0，另一类别梯度为 `1.5229979055675358e-8`。使用二分类恒等式 `log1p(exp(z1-z0))` 后，损失为 `1.5229979055675358e-8`，两维梯度分别为其负值和正值。详见 `results/pytorch_precision.json`。90 位 Decimal 参考是高精度数值近似，并非超越函数的严格误差证书。

2. **有限域上的符号证明。** 把指数和归约后的正小量抽象成 FP32 的 `s∈[2^-30,2^-24]`，舍入模式 RNE。Z3 证明 `fl(1+s)=1`，标准形式 `fl(fl(1/fl(1+s))-1)=0`，而改写的 `fl(-s/fl(1+s))<0`。真实数学目标梯度是 `-s/(1+s)`，因此标准形式的带符号误差恰为 `s/(1+s)`；用 FP32 位模式的整数量纲证明 `1/(2^30+1) ≤ error ≤ 1/(2^24+1)`，两个端点均可达到。SMT-LIB 查询在 `results/*.smt2`，结论在 `results/proofs.json`。此证明把 `s` 当作输入，不证明 PyTorch 的 `exp/log` 或整段 C++ 内核。

3. **Vortex 原始 RTL 的局部性质。** 对提交 `127178d6375c3cb525e2c8af0c77b5f2d52ed93e` 中未修改的 `VX_tcu_tfr_align.sv`、`VX_lzc.sv` 等模块，配置 `N=5, WI=25, WO=30, TCU_EXP_BITS=10`。Z3 对手工转写的 `sticky_bits` 表达式证明：它当且仅当启用 lane 的非零位在对齐右移中被丢弃时置 1。原始模块用轻量包与宏桩编译，在 Icarus 12 和 Verilator 5.020 上各通过 10,000 个输入向量、每个 5 lane 的 `sticky`、输出和符号检查。日志在 `results/vortex_iverilog.log` 与 `results/vortex_verilator.log`。这验证的是模块级组合逻辑，未证明整个 GPU/FPU 或真实芯片。

4. **Ventus 源码结构模型与 PyTorch 对比。** Ventus 提交 `681172541a8a34ffb43c483a19c075acbc11a4eb` 固定的 `fpuv2` 子模块为 `7ea30df00f9353f2e8645b32665b13f9b3f69e6d`。`Tensor.scala` 的 `TCDotProduct(4)` 明确先做四个乘法，再配对 `(0,2)`、`(1,3)`，再相加和加 `C`。假设每个乘加级按 IEEE FP32 RNE 输出，输入 `a=[2^24,1,1,-2^24], b=[1,1,1,1], C=0` 的模型结果为 **1**，精确整数结果为 **2**；本机 PyTorch `torch.dot` 为 **1**，同形状 `torch.matmul` 为 **0**。Z3 核对了模型在该输入上的结果；尚未运行 Ventus 生成的 RTL。详见 `results/ventus_tree_case.json`。

5. **625 个输入的完整枚举。** 取每个 `a_i∈{-2^24,-1,0,1,2^24}`、`b_i=1`，Ventus 结构模型和本机 `torch.dot` 的误差范围均为 `[-2,2]`，本机 `torch.matmul` 为 `[-3,3]`。两种 PyTorch API 在 88 个输入上结果不同。这个范围只针对明确列出的 625 个输入以及本机 PyTorch CPU 构建，不外推到所有 FP32 输入或 Ventus RTL。详见 `results/exhaustive_small_domain.json`。

## 安装与重跑

以下命令适用于 Ubuntu 24.04、Python 3.12。先安装 Git、C++ 编译器、Icarus Verilog 12 和 Verilator 5.020，并下载固定版本的 GPU 源码：

```bash
./setup_sources.sh
python3 -m venv .venv
.venv/bin/python -m pip install z3-solver==5.3.3 numpy==2.5.4
.venv/bin/python -m pip install 'torch==2.15.0+cpu' --index-url https://download.pytorch.org/whl/cpu
./run_all.sh
```

`run_all.sh` 运行 PyTorch CPU、Z3、Ventus 源码结构模型和 Vortex RTL 仿真。若仿真器不在 `PATH`，可以分别设置 `IVERILOG_BIN`、`VVP_BIN`、`VERILATOR_BIN`；Icarus 的支持文件在非标准目录时设置 `IVERILOG_BASE`。在原始节点上，脚本还会自动识别 `vendor/apt` 下的本地仿真器。

V100 或其他受对应 PyTorch wheel 支持的 CUDA 设备可以运行：

```bash
python3 -m venv .venv-cuda
.venv-cuda/bin/python -m pip install 'torch==2.14.1+cu126' --index-url https://download.pytorch.org/whl/cu126
.venv-cuda/bin/python -m pip install numpy==2.5.4
./run_cuda.sh
```

CPU 和 CUDA 虚拟环境的完整包版本分别在 `requirements-lock.txt` 和 `requirements-cuda-lock.txt`。`rtl_test/tb_tfr_align.sv` 一次赋值完整打包输入总线。开发时逐项驱动打包数组导致 Verilator 5.020 的测试台出现假失败；静态向量和整条总线赋值后，两种仿真器均通过。该过程没有产生可信的 Vortex RTL 缺陷证据。

## 下一步验证边界

- Ventus 的 `TCMulPipe`/`TCAddPipe` 仍需生成 Verilog，并用相同见证输入跑 RTL，核对每级舍入与异常行为；当前结果是源码结构模型。
- 需要将具体 PyTorch 算子后端的归约次序固定并建模，才能把它的误差界作为软件实现的形式化结论；当前 PyTorch 结果是实测和有限输入枚举。
- 已在单张 V100 上运行 PyTorch CUDA；尚未得到 Vortex 与 Ventus 整机的端到端精度界。

## V100 上的 PyTorch CUDA 对照

使用一张 Tesla V100（计算能力 7.0）、PyTorch `2.14.1+cu126`，其二进制构建包含 `sm_70`。设置 `CUDA_VISIBLE_DEVICES=0` 后，FP32 logits `[0,-18]` 的标准交叉熵梯度为 `[0,1.5229980832032197e-8]`，改写形式为 `[-1.5229980832032197e-8,1.5229980832032197e-8]`。同一组四项点积见证在 CUDA `torch.dot` 为 1、`torch.matmul` 为 0。625 个有限域输入的 CUDA 误差范围仍分别为 `[-2,2]` 和 `[-3,3]`，两 API 在 88 个输入上结果不同。详见 `results/pytorch_cuda_precision.json`。这些是 CUDA 软件栈在 V100 上的实测值，不是 Vortex 或 Ventus 的 RTL 输出。

### 同一 PyTorch 版本的 CPU/GPU 对照

在同一个 `2.14.1+cu126` 构建中，FP32 logits `[0,-18]` 的标准交叉熵目标梯度在 CPU 与 V100 都为 0，另一类梯度分别是 `1.5229979055675358e-8` 和 `1.5229980832032197e-8`，差 `1.7763568394002505e-15`（该量级的一个 FP32 ULP）。同版本的 625 个点积输入上，CPU 与 CUDA 的 `dot` 相互一致，`matmul` 也相互一致；`dot` 与 `matmul` 之间的 88 个差异仍然存在。详见 `results/pytorch_cpu_cuda_matched.json`。此对照固定了 PyTorch 版本，但不固定 CPU 与 CUDA 的底层 `exp` 实现。
