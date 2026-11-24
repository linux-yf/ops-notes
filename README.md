# 仓库目录结构规划

```tex
ops-notes/
├── assets/                        # 全站图片（已建好）
├── 00-Inbox/                      # 收件箱：随手记、待整理的碎片
│   └── README.md                  # 说明：什么东西该进来、什么时候清空
├── 01-incident/                   # 故障案例库（价值最高，重点维护）
│   ├── gpu/                       # GPU 硬件类：Xid 错误、ECC、掉卡、NVLink、温度告警
│   ├── inference-engine/          # 推理引擎类：vLLM OOM、TTFT 劣化、KV Cache 异常、内核崩溃
│   ├── k8s/                       # 调度与容器类：Pod 驱逐、调度失败、镜像拉取、PVC
│   └── network/                   # 网络类：NCCL 超时、RDMA、Service 不通、DNS
├── 02-runbook/                    # 应急手册：出事时照着做的步骤
│   ├── gpu/                       # 掉卡重启流程、GPU 节点隔离流程
│   ├── inference/                 # 服务回滚流程、限流降级预案、流量切换
│   └── cluster/                   # 节点摘除/恢复、紧急扩容
├── 03-sop/                        # 标准操作：日常例行、不出事也常做的
│   ├── deploy/                    # 模型发布上线流程、版本灰度
│   ├── monitor/                   # 巡检项清单、告警规则维护
│   └── capacity/                  # 容量评估、租户配额调整
├── 04-config/                     # 配置与代码片段
│   ├── prometheus/                # 告警规则、exporter 配置、Grafana 面板 JSON
│   ├── vllm/                      # 启动参数模板、部署 YAML
│   └── scripts/                   # 常用排查脚本（bat/py/sh）
├── 05-learning/                   # 学习笔记：原理、机制、踩坑原理分析
│   ├── llm-inference/             # 推理框架原理、量化、KV Cache 机制
│   └── infra/                     # K8s 原理、GPU 虚拟化、存储网络
├── 06-Windows-app/				   # 分享一些Windows软件的配置使用
├── git-sync.bat                   # 同步脚本（留在根目录）
└── README.md                      # 仓库导航：各目录放什么、怎么用模板
```

## 两条维护规则

1. **Inbox 定期清空**：每周花点时间把 00-Inbox 里的碎片归档进对应目录；归档动作本身就是二次加工，正是知识内化的过程
2. **目录宁缺毋滥**：只建当前用得上的目录。比如现在还没用到 RDMA，就别先建 `network/rdma/`，等真出现第一篇相关笔记再细分

