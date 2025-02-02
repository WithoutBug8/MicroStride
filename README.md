## 习惯分析软件-ios版本开发日志

### 理论验证阶段

$$
\begin{align*}
    V_t &= \beta(t) \cdot \delta(t)^t \cdot V_0  &\quad \text{（计算未来价值 $V_t$）} \\
    \beta(t) &= \beta(t - 1) + 0.01  &\quad \text{（习惯保持函数）} \\  
    \beta(t) &= \beta(t - 1) - 0.0014 &\quad \text{（习惯衰减函数）} \\  
    \delta(t) &= \delta(t - 1) + 0.0001  &\quad \text{（未来预期回报增加函数）} \\  
    \delta(t) &= \delta(t - 1) - 0.00014  &\quad \text{（未来预期回报减少函数）} 
\end{align*}
$$

给出实现条件，假设V₀=100，t=10,养成一个习惯，下面是连续坚持10天，和连续摆烂10天的具体数据

| 第N天 | 坚持自律           | 选择摆烂          |
| ----- | ------------------ | ----------------- |
| 0     | 100                | 100               |
| 1     | 101.0101           | 98.58619599999999 |
| 2     | 102.04080408       | 97.14557562048    |
| 3     | 103.092727812781   | 95.67934269026237 |
| 4     | 104.16649986662665 | 94.18872155673668 |
| 5     | 105.26276263128278 | 92.6749553811216  |
| 6     | 106.38217285812608 | 91.13930440925014 |
| 7     | 107.5254023154345  | 89.58304422124708 |
| 8     | 108.6931384596745  | 88.00746396350628 |
| 9     | 109.88608512374289 | 86.41386456640105 |
| 10    | 111.10496322312764 | 84.80355695118291 |

但是这个模型的问题在于，当天数比如是1000天或者更大，会发生数据爆炸，数据增长的太快了，不适合描述习惯培养过程中的自律和摆烂的状态，最终选择放弃改模型。

$$
\begin{aligned}
V_t &= V_{t-1} + \beta_t \cdot X_t \cdot (1 - V_{t-1}) - \gamma \cdot (1 - X_t) \cdot V_{t-1} \\
\text{其中：} \\
V_t &: \text{第 } t \text{ 天的习惯强度，范围 } (0 \leq V_t \leq 1)。 \\
V_{t-1} &: \text{前一天的习惯值，由前一天的计算结果决定}。 \\
\beta_t &: \text{习惯增长速率，控制自律行为对习惯的提升程度}。 \\
X_t &: \text{当天是否自律}，X_t = 1 \text{ 表示自律，} X_t = 0 \text{ 表示摆烂}。 \\
\gamma &: \text{习惯遗忘速率，控制摆烂时习惯值的下降幅度}。
\end{aligned}
$$


请看实际的代码

```python
# 新的数学模型描述习惯养成
import numpy as np
import matplotlib.pyplot as plt

# 设置参数
num_days = 10
V_0 = 0.1  # 初始习惯值
beta_t = 0.2  # 习惯养成速度
gamma = 0.1  # 习惯遗忘速度

# 生成随机的自律和摆烂天数
np.random.seed(42)
habit_success = np.random.choice([1, 0], size=num_days, p=[0.7,0.3])  # 前一个参数自律，后一个参数摆烂

# 计算 V_t
V_t = np.zeros(num_days)
V_t[0] = V_0

for t in range(1, num_days):
    if habit_success[t]:  # 自律
        V_t[t] = V_t[t-1] + beta_t * (1 - V_t[t-1])
    else:  # 摆烂
        V_t[t] = V_t[t-1] - gamma * V_t[t-1]

# 打印 V_t 的值，标注当天的状态
for t in range(num_days):
    status = "自律" if habit_success[t] else "摆烂"
    print(f"Day {t+1}: V_t = {V_t[t]:.4f} ({status})")


# 画图
plt.figure(figsize=(8, 5))
plt.plot(range(1, num_days + 1), V_t, marker='o', linestyle='-', label="Habit Strength (V_t)")
plt.xlabel("Days")
plt.ylabel("Habit Strength")
plt.title("Habit Formation vs. Decay Over Time")
plt.axhline(y=1, color='r', linestyle='--', label="Max Habit Strength")
plt.legend()
plt.grid(True)
plt.show()
```

运行结果如下所示

```markdown
Day 1: V_t = 0.1000 (自律)
Day 2: V_t = 0.0900 (摆烂)
Day 3: V_t = 0.0810 (摆烂)
Day 4: V_t = 0.2648 (自律)
Day 5: V_t = 0.4118 (自律)
Day 6: V_t = 0.5295 (自律)
Day 7: V_t = 0.6236 (自律)
Day 8: V_t = 0.5612 (摆烂)
Day 9: V_t = 0.6490 (自律)
Day 10: V_t = 0.5841 (摆烂)
```

