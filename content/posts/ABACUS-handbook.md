---
title: "ABACUS简明手册"
Authors: MingLong Wang, SiKe Zeng
date: 2024-02-03
categories:
   - Manual
---

> [!cite] 
> [Abacus](https://abacus.ustc.edu.cn/main.htm)
> [相关软件的手册](https://abacus.ustc.edu.cn/manual/list.htm)
> [新人使用注意事项](https://xmywuqhxb0.feishu.cn/docx/KN3KdqbX6o9S6xxtbtCcD5YPnue)

# Introduction

`ABACUS` 是一个可以选择平面波 pw 基组或者 LCAO 原子轨道基组进行 DFT 计算的软件包。

LCAO 基组的好处是相对平面波基组更小，因此计算的效率更高，虽然精度相对会低一点，相当于在计算速度和精度之间重新寻找了一个平衡点。

除此之外，由于使用原子轨道基，在一些特定的情况下，例如计算 BPVE 体光伏效应的时候，不用再使用 `wannier90` 拟合哈密顿量，减少了误差出现的可能性，优化工作流。

并且在这个生态下还有其他的软件可以方便的使用，例如 `DeePMD`、`PYATB` 等等。

**[Bohrium Chat](https://bohrium-chat.dp.tech/#/chat) 有什么问题可以问他们社区的 GPT**。

---

下面是官方介绍

> ABACUS (Atomic-orbital Based Ab-initio Computation at UStc) is an open-source computer code package aiming for large-scale electronic-structure simulations from first principles, developed at the Key Laboratory of Quantum Information and Supercomputing Center, University of Science and Technology of China (USTC) - Computer Network and Information Center, Chinese of Academy (CNIC of CAS).

ABACUS currently provides the following features and functionalities:
1. Three types of supported basis sets: pw, LCAO, and LCAO-in-pw.
2. Ground-state total energy calculations using Kohn-Sham (KS) density functional theory (DFT) with local-density, generalized gradient approximations (LDA/GGAs), Meta-GGA (requires LIBXC, only for PW), and hybrid functionals (PBE0 and HSE06, only for LCAO and currently under test).
3. Geometry relaxations with Conjugated Gradient (CG), BFGS, and FIRE methods.
4. Semi-empirical van der Waals energy correction using the Grimme DFT-D2/D3 scheme.
5. NVT and NVE molecular dynamics simulation. AIMD, DP potential, LJ potential are supported.
6. Stress calculation and cell relaxation.
7. Electric polarization calculation using Berry Phase theory.
8. Interface to the Wannier90 package.
9. Real-time time dependent density functional theory (TDDFT).
10. Print-out of the electrostatic potential.
11. Mulliken charge analysis (only for LCAO).
12. Projected density of states (PDOS) (only for LCAO).
13. DFT+U calculation (only for LCAO).
14. ...

# How to submit

Here is a simple script to submit the job. 
```job.sh
#!/bin/bash
#SBATCH -J TASK
#SBATCH -p sonmi_1 -N 1 -n 40

ulimit -s unlimited

module load abacus
echo 'This program is running at'  `hostname`
mpirun -n ${SLURM_NPROCS} abacus
```
由于这个软件使用的是 `intel-2023` 编译器，因此在有些节点上可能无法使用。

# 辅助软件-用于准备相应输入文件

![[Pasted image 20240118173627.png]]

## `atomkit`

和 `vaspkit` 是同一个开发组，使用方式也一样，以前用 `vaspkit` 的同学可以无缝衔接。但是 `atomkit` 还在测试中，需要加 qq 群获取安装包，有需要的可以联系管理员。
（或者我有空装到 `module` 中）

## `dpdata`

![[dpdata-handbook#Introduction]]

# 赝势和轨道文件 `pseudo_dir` and `orbital_dir`

> [轨道文件的基本说明](https://xmywuqhxb0.feishu.cn/docx/M6M2dJj4moBL05xaMtLc8sf1nub)

- 在 INPUT 文件中用 `basis_type` 来确定是平面波基组（pw）还是原子轨道的线性组合（lcao），**默认是前者**，使用后者要在 STRU 文件中写入原子轨道基组的信息
- ABACUS 没有 POTCAR 文件，而是将 POTCAR 文件变成地址调用，在 INPUT 中写好地址，STRU 文件中选择调用的具体文件名，轨道信息也是如此

计算需要赝势库 [PSEUDOPOTENTIALS AND ORBITALS](https://abacus.ustc.edu.cn/pseudo/list.htm)

![[Pasted image 20240109171014.png]]

```INPUT
pseudo_dir          /share/home/wangml/SG15_ONCV_v1.0_upf
orbital_dir         /share/home/wangml/SG15-Version1p0__StandardOrbitals-Version2p0
```

1. 训练 DP 势需要先进行收敛性测试，需要下载的是包含所有轨道基组的包，而不是只包含推荐设置的 standard 的包。（*但是 `atomkit` 自动转换的 `STRU` 只能指定 standard 版本的轨道文件，如欲测试其他轨道文件，需手动修改*）
2. 下载完成后通过轨道文件的名字判断该轨道的精度等级（以 Si 为例）：![[Pasted image 20240126131643.png]]
  1. **DZP 精度<TZDP， DZP 效率优于 TZDP**
  2. “Si_gga_6au_100Ry_2s2p1d. Orb”
    1. `Si` : 元素名，需要确认和赝势中元素相同
    2. `gga`：对应的赝势中的交换关联泛函版本，目前只提供了 GGA-PBE 的
    3. `6au`：轨道截断半径，越小越快，越大越准，需要收敛性测试
    4. `100Ry`：说明精度锚定的是 `ecutwfc = 100Ry` 的 PW 基组计算结果，作为参数设置推荐值，ecutwfc 不需要进行收敛性测试
    5. `2s2p1d`：轨道文件中包含的轨道数量，越多越准，越少越快，不需要收敛性测试，只需要判断 scf 收敛的电子结构性质结果精度是否符合需求，一般来说 DZP 是够用的，不排除特例。

和 PW 基组一样，对 k 点的收敛性测试也是需要的。

# Input Files

> [Brief Introduction of the Input Files — ABACUS documentation](https://abacus.deepmodeling.com/en/latest/quick_start/input.html)
> [周巍青：密度泛函理论与ABACUS简介\_哔哩哔哩\_bilibili](https://www.bilibili.com/video/BV1Bc41147vg/?spm_id_from=333.337.search-card.all.click&vd_source=a927cbf9ea7106abc8e72b377926f35e)

## `INPUT` 基本参数

需要注意，**这个软件的单位和 `vasp` 不一样，例如 `ecutwfc`**。因此在**进行参数转换的时候一定一定要慎重**。

简单的 `INPUT` 文件如下所示
```
INPUT_PARAMETERS
suffix                  MgO # the name of system
ntype                   2 # how many types of elements in the unit cell
pseudo_dir              ./
orbital_dir		./
ecutwfc                 100             # Rydberg
scf_thr                 1e-4		# Rydberg
basis_type              lcao            
calculation             scf		# this is the key parameter telling abacus to do a scf calculation
out_chg			True
```

---

`INPUT` 文件需要以 `INPUT_PARAMETERS` 先行词开头，该词前面的内容都会被忽略掉。输入参数有很多, 具体请查看手册，这里列举几种情况的输入文件怎么写。
下面整理一些常用的参数

| 参数名 | 取值 (VASP 中对应的取值)) | 注释 | VASP |
| :--: | :--: | :--: | :--: |
| scf_thr | 实数 | 电荷密度收敛条件，计算两次电子步的电荷密度差值，来确定是否退出电子迭代，与 vasp 中的 EDIFF 起到的作用一样 | EDIFF |
| suffix |  | 系统名称 | SYSTEM |
| ntype | 实数 | 原子种类数，可以不设置，ABACUS 会根据 STRU 文件来自动确定原子种类会 |  |
| pseudo_dir |  | 赝势文件地址 |  |
| orbital_dir |  | 轨道文件地址（pw 基组可以不写） |  |
| ecutwfc | 如果选的是 lcao 基组，那么最好和轨道文件选取一致（看文件名） | 平面波的截断能，这里的单位是 Ry | ENCUT |
| basis_type | lcao/pw | 基组的选取 |  |
| calculation | Tip 1 | 计算的类型 |  |
| init_chg | Tip 2 | 初始电荷密度的设置 | ICHARG |
| init_wfc | Tip 2 | 初始波函数的设置，只有选了 pw 基组才需要设置 w | ISTART |
| out_chg | T/F | 是否输出电荷密度文件 | LCHARG |
| out_wfc_pw | 0/1/2 | 是否输出波函数 | LWAVE |
| scf_nmax |  | 电子步的最大值 | NELM |
| smearing_method | fixed（ISMEAR=-2）/gauss （ISMEAR=0）/mp （ISMEAR>0）/fd（ISMEAR=-1）) | 轨道占据的方式 | ISMEAR |
| smearing_sigma |  | the width of the smearing in eV | SIGMA |
| nspin | 1 (ISPIN=1)/2 (ISPIN=2)/4 （2 是共线自旋计算，4 是非共线自旋计算) | 考不考虑自旋 | ISPIN |

> [!example] Tip 1：关于 `calculation` 参数的取值
> 1、静态计算：scf
> 2、结构优化：relax 或者 cell-relax
> 3、非自洽计算：nscf
> 4、分子动力学模拟：md
> 
> **具体计算细节见后续小节**

> [!example] Tip 2：电荷密度和波函数相关设置
> 1、init_chg 有 `atomic` 和 `file` 两种取值，前者是根据原子密度求和得到初始电荷密度，后者是直接从电荷密度文件读取。
> 2、电荷密度文件可以通过设置参数 `out_chg` 为 Ture 来输出，输出文件名后缀为 `.cube`。
> 3、init_wfc 的取值为 `atomic` `random` `atomic+random` `file` 四种。PW 基组建议使用 `atomic` ，LCAO 基组建议使用 `file`。
> 4、波函数的输出有两种，`out_wfc_pw` 和 `out_wfc_lcao`, 应该是基组不一样。当它们取 0 时，不输出，取 1 时输出的波函数文件是 txt 格式，取 2 时是二进制文件。

## `STRU` 结构文件

![[Pasted image 20240118173533.png]]

> [!tip] 原子坐标的进阶写法
> 1、在做结构优化的时候，如果要固定某些原子不动，某些原子动，则在原子坐标后面加上 `m 0 0 0` 或 `m 1 1 1`,0 代表不动，1 代表允许移动。例如上面硅的例子, 原子坐标改为：
  -0.125  -0.125  -0.125    m 0 0 0
   0.125   0.125   0.125    m 1 1 1 
  表示第一个原子不动，第二个原子可移动。M 可以省略。
  >
  2、如果要设置每个原子磁矩不同，或者非共线磁时，在每个原子坐标后面加关键词 `mag` 来编写原子磁矩，共线磁只需一个数，非共线磁要三个数，与 `vasp` 中的 `MAGMOM` 参数一致。
  >
  3、如果要设置共线反铁磁，则设置两种原子，其他参数都一样，但一种磁矩为 m，另一种为-m。


### `STRU` 格式转换-方案 0

最方便的方案，下载 `atomkit`，使用方式和 `vaspkit` 一样。

### `STRU` 格式转换-方案 1

> [deepmodeling/dpdata-github](https://github.com/deepmodeling/dpdata)
> [[dpdata-handbook]]

安装略（需要安装 `conda+Python`），在组内集群可以直接运行 `pip install dpdata`

使用
```shell
conda activate dpdata # or any env contain python>=3
python
```
进入 `python` 后
```python
import dpdata
#poscar 转为 stru
ls = dpdata.System(file_name='POSCAR',fmt='poscar')
ls.to(file_name="STRU",fmt='abacus/stru')

#stru 转为 poscar
ls = dpdata.System(file_name="STRU",fmt='abacus/stru')
ls.to(file_name='POSCAR',fmt='poscar')
```

### `STRU` 格式转换-方案 2

> [ABACUS 使用教程｜如何转换 STRU 文件](https://nb.bohrium.dp.tech/detail/9814968648)

这里使用的是 `Python ASE-ABACUS` 接口，和上面的方案一样，都需要 `Python` 环境。

上面的软件应该有前缀 `dp`，应该也是一个社区开发的。

> [!info] [jiyuyang / ase-abacus · GitLab](https://gitlab.com/1041176461/ase-abacus)
> [ASE](https://wiki.fysik.dtu.dk/ase/) (Atomic Simulation Environment) provides a set of Python tools for setting, running, and analysing atomic simulations. We have developed an [ABACUS](http://abacus.ustc.edu.cn/) calculator (ase-abacus) to be used together with the ASE tools, which exists as an external project with respect to ASE and is maintained by ABACUS developers.

所以这个软件相当于一个工具合集，或许正式教程中直接安装这个会更好。

如果组里要装，最好的方式就是看看怎么启用 `conda`，大家要用就默认启用这个模组，或者在 `module` 里面 `activate conda env-abacus`，如果各自有需要就 clone 一个 environment.

**现阶段对我来说最有用的还是它有 MD Analysis**

## `KPT` 计算网格

这里利用 `atomkit` 生成 `KPT`
```
echo -e "301\n0\n101 STRU\n0.03" | atomkit
# or you can just type `atomkit` and follow the guide
```

# 结构优化

`ABACUS` 提供了两种结构优化的方法 `relax` 和 `cell-relax`。前者其实对应于 `VASP` 里面的 `ISIF=2`，就是优化原子位置，但不优化晶格矢量（晶胞）；后者则对应 `ISIF=3`，既优化晶胞，又优化原子位置。当然也可以固定原子位置进行优化，具体见 [[ABACUS-handbook#`STRU` 结构文件]] 章节。

下面表格是结构优化可能用到的参数。

| 参数名 | 取值（默认值） | 注释 | VASP |
| :--: | :--: | :--: | :--: |
| calculation | relax | - | ISIF=2 |
| calculation | cell-relax | - | ISIF=3 |
| relax_method | cg/bfgs/cg_bfgs/sd/fire（cg） | Tip 1 | IBRION |
| relax_nmax | 实数 (1) | 最大离子步 | NSW |
| force_thr_ev | 实数（0.0257112） | 力收敛的条件 | EDIFFG |
| cal_stress | T/F (True if calculation is cell-relax, False otherwise) | 是否计算应力 |  |
| stress_thr | 实数（0.5） | 应力收敛的阈值 |  |
| fixed_axes | None/volume/shape/a/b/c/ab/ac/bc | 固定原胞参数 |  |
| out_stru | T/F (F)) | 是否输出结构文件 |  |

## `opt_INPUT`

```INPUT
INPUT_PARAMETERS
#Parameters (1.General)
pseudo_dir          /share/home/wangml/SG15_ONCV_v1.0_upf
orbital_dir         /share/home/wangml/SG15-Version1p0__StandardOrbitals-Version2p0
ntype               5
calculation         cell-relax

#Parameters (2.SCF)
ecutwfc             100
scf_thr             1e-5

smearing_method		gauss
smearing_sigma			0.01

#Parameters (3.Basis)
basis_type          lcao
force_thr_ev		0.01		# the threshold of the force convergence, in unit of eV/Angstrom
stress_thr		2		# the threshold of the stress convergence, in unit of kBar
relax_nmax		100		# the maximal number of ionic iteration steps
out_stru		1

##Parameter DFT+U
dft_plus_u    1
orbital_corr    2 -1 -1 -1 -1
hubbard_u    4 0 0 0 0
```

# 自洽计算 SCF

## `scf_INPUT`

```INPUT
INPUT_PARAMETERS
#Parameters (1.General)
pseudo_dir          /share/home/wangml/SG15_ONCV_v1.0_upf
orbital_dir         /share/home/wangml/SG15-Version1p0__StandardOrbitals-Version2p0
ntype               5
calculation         scf

#Parameters (2.SCF)
ecutwfc             100
scf_thr             1e-7
scf_nmax	        100


#Parameters (3.Basis)
basis_type          lcao

smearing_method     gauss
smearing_sigma      0.015

##Parameter DFT+U
dft_plus_u    1
orbital_corr    2 -1 -1 -1 -1
hubbard_u    4 0 0 0 0

#Parameters (File)
out_chg                         1
```

### SCF-续算

`init_chg` is used for choosing the method of charge density initialization.
- `atomic` : initial charge density by atomic charge density from pseudopotential file under keyword `PP_RHOATOM`
- `file` : initial charge density from files produced by previous calculations with [`out_chg 1`](https://abacus.deepmodeling.com/en/latest/advanced/elec_properties/charge.html).

## SCF-输出

![[Pasted image 20240118215036.png]]

# DFT+U

| 参数名 | 取值 | 含义 | vasp 对应 |
| ---- | ---- | ---- | ---- |
| dft_plus_u | T/F | 加不加 UU | LDAU |
| orbital_corr | -1,1,2,3 | -1 代表该原子不加，1/2/3 代表 p/d/f 轨道加 U | LDAUL |
| hubbard_u |  | 加 U 的大小 U | LDAUU minus LDAUJ |
| yukawa_potential | T/F | 采用局域屏蔽库伦势计算 U 值 U |  |

# 其他

想找其他类型计算的参数设置，或者这个社区其他软件包的使用教程，都可以去 [bohrium社区](https://nb.bohrium.dp.tech/cases)中寻找 Notebook。

## 输出文件

所有的输出文件都在 `OUT.suffix` 文件夹中。
- `INPUT` 计算中所有使用的参数
- `STRU_ION_D` 结构优化结果文件
- `SPIN1_CHG.cube` 电荷密度文件
- `running_scf.log` 计算细节，等同于 `OUTCAR`

## 数据和图像处理

这个社区有提供相应的 `python` 代码画图，可以在集群上直接安装 `jupyter-notebook` ，在服务器上进行简单的绘图，分析计算结果。

# 一些注意事项

> [新人使用注意事项](https://xmywuqhxb0.feishu.cn/docx/KN3KdqbX6o9S6xxtbtCcD5YPnue)

1. 用 LCAO 计算有真空层的体系时，**不要把真空层设置在 Z 方向**，目前 ABACUS 的格点积分（与原子位置有关）是在 Z 方向进行并行的，这样会造成资源浪费。PW 计算没有这种考虑。
2.   ABACUS 的输入参数中，长度单位通常为 Bohr，能量单位通常为 Ry。 
	1. 1 Angstrom ~= 1.889716 Bohr
	2. 1 Ry ~= 13.6 eV
3. **ecutwfc**：对应 VASP 的**ENCUT**，单位为 Ry。VASP 常用 PAW 赝势，ABACUS 常用模守恒赝势。使用 ABACUS 时不能直接用 VASP 的能量截断值，需重新做收敛性测试，一般模守恒赝势需要的截断值更大。

