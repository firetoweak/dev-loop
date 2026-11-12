# dev-loop 技能包

工程师 + Agent 开发周期的一组 skill，外加一张开发地图。和具体工具、具体项目都无关：每个 skill 都是标准的 `SKILL.md`，可以给 Codex、Claude Code、Cursor 等任何读取 skill 文件夹的工具使用。

## 里面有什么

| 文件 | 给谁看 | 作用 |
|---|---|---|
| [MAP.md](MAP.md) | 我 | 开发地图：按情境查该做什么、判断规模、各阶段卡片、项目本地地图、模板 |
| `skills/dev-loop` | Agent | 入口：判断规模和阶段，选出该用的那一个 skill |
| `skills/spec-gate` | Agent | 确认交付物、盘点现状、列出阻塞问题（需求阶段） |
| `skills/runtime-judge` | Agent | 锁、线程池、队列、常驻内存、超时、静默降级（执行方式） |
| `skills/state-judge` | Agent | 幂等、一致、原子、数据访问成本（持久化） |
| `skills/change-discipline` | Agent | 每次修 bug、改已有行为的纪律 |
| `skills/delivery-gate` | Agent | 自验、交付说明、反馈分类、定稿点 |
| `skills/retro-to-rules` | Agent | 复盘并把教训写成会被执行的规则 |
| `install.sh` | — | 把 skill 链接到各工具的 skill 文件夹 |

每个 skill 开头都先判断规模（轻 / 标准 / 完整），小事小办。

## 安装

```bash
./install.sh
```

默认链接到本机已安装工具的用户级 skill 文件夹（`~/.codex/skills`、`~/.claude/skills`、`~/.cursor/skills`、`~/.agents/skills`，只处理工具已存在的）。Windows 上用目录联接（junction），不需要管理员权限；macOS / Linux 用符号链接。

其他用法：

```bash
./install.sh <项目>/.claude/skills       # 装到指定文件夹（例如某个项目里）
./install.sh --copy <文件夹>             # 工具不认链接时改为复制
./install.sh --uninstall                 # 移除本包创建的链接或副本
```

## 修改与优化

- **只在这里改。** 各工具看到的都是链接，改一处全部生效（`--copy` 安装的除外，需要重新复制）。
- 通用经验改 skill 或 MAP.md；只属于某个项目的经验写进那个项目的 `AGENTS.md`、规格、决策记录或约束文档，不写进这里。
- skill 正文用英文写给 Agent 读，不出现项目名；MAP.md 用中文写给自己看。
- 改完在 [CHANGELOG.md](CHANGELOG.md) 记一行。
