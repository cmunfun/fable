import Foundation

extension StoryCatalog {
    static let additionalStories: [FableStory] = [
        FableStory(
            id: "tallest-wheat",
            title: "只量最高的麦子",
            teaser: "村长想让麦田丰收，最后却只收获了一张漂亮的表。",
            category: "管理学 · 衡量",
            topics: [.incentives, .systems],
            coverAssetName: "cover-tall-wheat",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "好心的尺子", text: "村长想知道哪块地种得最好。收成尚未到来，他便让记录员每周量一次麦秆高度，并给最高的田发奖金。\n\n第一周，麦秆高度确实能反映长势。村民觉得这个办法公平又省事。"),
                StoryScene(number: 2, title: "越来越高", text: "第二周起，有人多施只催长叶茎的肥料，有人把麦苗种得更密。麦田像比赛一样往上蹿。\n\n记录员兴奋地把数字写满木板。村长望着齐整的高麦，提前安排了更大的粮仓。"),
                StoryScene(number: 3, title: "空了一半的粮仓", text: "秋天，最高的几块田反倒结穗稀疏。过密的麦苗争光争水，风一来又倒下一片。\n\n一位农夫说，他早知道会这样，却不敢落后于奖金榜；旁边的人也都在追逐同一把尺子。"),
                StoryScene(number: 4, title: "尺子变了用途", text: "村长说：“去年，高度是丰收的迹象；今年，它怎么失灵了？”\n\n记录员指着奖金榜回答：“去年我们用尺子观察麦田。今年大家用麦田追赶尺子。”村长终于看见，指标一旦决定奖赏，就会改变被衡量的行为。")
            ],
            recallPrompt: "客服团队因“平均通话时长越短越好”而迅速挂断复杂问题。这最像什么？",
            choices: [
                StoryChoice(title: "古德哈特定律", explanation: "对。指标成了奖惩目标，人们开始优化数字，数字与真正目标脱节。"),
                StoryChoice(title: "卢卡斯批判", explanation: "卢卡斯批判强调规则改变后旧行为关系未必可用于预测；这里更直接的问题是指标被当成目标后失真。"),
                StoryChoice(title: "边际收益递减", explanation: "边际收益递减讨论继续投入同一资源时额外收益下降，不能解释挂断电话的激励。")
            ],
            concept: "Goodhart's Law",
            conceptChinese: "古德哈特定律",
            insight: "当指标成了目标，它就可能失去衡量目标的能力。",
            explanation: "指标原本只是复杂目标的代理。若奖惩直接绑在指标上，参与者会寻找提高数字的办法，其中一些办法不会改善真正想要的结果。",
            businessExample: "只按处理工单数量奖励客服，可能让团队拆分工单或草率关闭问题。应同时观察解决率、复联率和用户反馈。",
            comparison: "它聚焦指标被追逐后的失真；卢卡斯批判更广泛地提醒我们，规则变化会使旧数据中的行为关系不再稳定。",
            words: [
                StoryWord(term: "Proxy", origin: "英语 proxy，源于 procuracy", meaning: "代替直接目标的代理指标"),
                StoryWord(term: "Metric", origin: "希腊语 metron", meaning: "用来衡量的尺度"),
                StoryWord(term: "Incentive", origin: "拉丁语 incinere", meaning: "促使行动的激励")
            ]
        ),
        FableStory(
            id: "bridge-builder",
            title: "桥匠的两份账",
            teaser: "桥建得越便宜，城主越高兴；修桥的钱却越来越多。",
            category: "组织经济学",
            topics: [.incentives, .information],
            coverAssetName: "cover-bridge",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "一座桥", text: "河水隔开了两片集市。城主请来桥匠，约定只要在预算内把桥建成，就给他一笔奖金。\n\n城主不会造桥，也无法每天守在工地。他能看到花了多少钱，却看不出木梁里藏着多少裂纹。"),
                StoryScene(number: 2, title: "省下的钱", text: "桥匠发现，用便宜木料和少涂一层防潮油，就能把账面成本压得很低。奖金立刻可以拿到，木梁坏掉却是几年后的事。\n\n他并不想让桥塌，只是每次都选了对自己更划算的做法。"),
                StoryScene(number: 3, title: "雨季之后", text: "第一年，城主夸桥匠节俭。第二年雨季，桥面开始松动。修缮费用比当初省下的钱还多，商队也被迫绕路。\n\n城主追问桥匠为何不多花一点钱。桥匠答：“您奖励的是完工时的低成本。”"),
                StoryScene(number: 4, title: "改写契约", text: "城主请木匠独立验收，把部分报酬留到几轮雨季之后，再根据桥的耐用程度发放。\n\n他明白，委托别人做自己看不见的工作时，光说“把桥建好”不够；报酬和检查方式也在决定桥会被怎样建。")
            ],
            recallPrompt: "外包团队按上线速度拿奖金，而系统故障由客户承担。核心问题是什么？",
            choices: [
                StoryChoice(title: "委托代理问题", explanation: "对。委托人和代理人的目标不同，委托人又难以观察全部行动。"),
                StoryChoice(title: "逆向选择", explanation: "逆向选择关注签约前隐藏的类型或质量；这里主要是签约后工作方式无法被充分观察。"),
                StoryChoice(title: "网络效应", explanation: "网络效应关注用户数量如何影响产品价值，与这份合同的激励错位无关。")
            ],
            concept: "Principal–Agent Problem",
            conceptChinese: "委托代理问题",
            insight: "当做决定的人不承担全部后果，契约就会塑造他的选择。",
            explanation: "委托人把任务交给代理人，但双方目标不完全相同，且委托人无法观察全部行动。若报酬与真正结果脱节，代理人可能合理地优化自己的收益，却损害委托人的目标。",
            businessExample: "企业把软件开发外包后，若只按交付日期付款，供应商可能牺牲可维护性。分阶段验收、质量指标和后续维护责任能缓和这一问题。",
            comparison: "委托代理问题描述目标不一致与信息不对称的整体关系；道德风险特指交易后隐藏行动引发的风险，是其中常见的一种表现。",
            words: [
                StoryWord(term: "Principal", origin: "拉丁语 principalis", meaning: "委托任务的一方"),
                StoryWord(term: "Agent", origin: "拉丁语 agere", meaning: "代他人行动的一方"),
                StoryWord(term: "Alignment", origin: "英语 align", meaning: "让激励与目标方向一致")
            ]
        ),
        FableStory(
            id: "blue-sail",
            title: "蓝帆船会不会回来",
            teaser: "等船的人有了新消息，却差点只挑自己爱听的。",
            category: "推理 · 决策",
            topics: [.decisions, .uncertainty],
            coverAssetName: "cover-blue-sail",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "出海之前", text: "港口里有十艘远行船。过去的记录显示，八艘会在月圆前回来，两艘常因远航延迟。\n\n一位商人等着一艘挂蓝帆的船。他先按旧记录估计，这艘船按时归来的机会大约是十分之八。"),
                StoryScene(number: 2, title: "灯塔的消息", text: "三天后，灯塔报告看见蓝色帆影。商人很想立刻宣布船已归来。\n\n守塔人提醒他：真正按时回来的蓝帆船，十次有九次会被看见；未回来的时候，远处的蓝旗或云影也可能被误认，十次里有两次会报出同样消息。"),
                StoryScene(number: 3, title: "不只看好消息", text: "商人把十次相似的等待画在纸上：约八次本来会按时回来，其中约七次能看到蓝帆；约两次不会按时回来，其中仍可能有不到一次的误报。\n\n看到帆影确实是好消息，但它不是百分之百的保证。"),
                StoryScene(number: 4, title: "改变多少", text: "商人没有把旧判断扔掉，也没有把新报告当成铁证。他同时看“原本有多可能”和“这条消息在两种情况下各有多常见”。\n\n他决定先准备卸货工人，再等船靠岸后支付尾款。新证据让他的判断更有把握，也让行动更稳妥。")
            ],
            recallPrompt: "检测结果为阳性时，你同时考虑疾病原本有多常见和误报率。这是什么思路？",
            choices: [
                StoryChoice(title: "贝叶斯更新", explanation: "对。先验判断要结合新证据在不同情况下出现的可能性一起更新。"),
                StoryChoice(title: "幸存者偏差", explanation: "幸存者偏差是只看到留下来的样本而忽略缺席者，与这次更新概率的步骤不同。"),
                StoryChoice(title: "锚定效应", explanation: "锚定效应是过度依赖最初数字；合理的更新会依据证据修正最初判断。")
            ],
            concept: "Bayesian Updating",
            conceptChinese: "贝叶斯更新",
            insight: "新证据的力量，取决于它在不同解释下有多常见。",
            explanation: "先从已有信息形成先验概率，再比较新证据在各种可能情形下出现的概率，得到更新后的判断。一个看似有力的信号，若误报常见，仍不该被当作确定答案。",
            businessExample: "某产品的异常报警即使很准确，也要结合真实故障率和误报率决定是否停机，避免把每条警报都当成确定故障。",
            comparison: "贝叶斯更新是一种依据证据修正概率的方法；锚定效应则是心理上过度受初始信息影响，使修正不足。",
            words: [
                StoryWord(term: "Prior", origin: "拉丁语 prior", meaning: "看到新证据前的判断"),
                StoryWord(term: "Likelihood", origin: "英语 likely", meaning: "某种假设下出现这条证据的可能性"),
                StoryWord(term: "Posterior", origin: "拉丁语 posterior", meaning: "结合证据后更新的判断")
            ]
        ),
        FableStory(
            id: "empty-plot",
            title: "留白的河岸",
            teaser: "两条路都能赚钱，村民却决定先不把第三条路堵死。",
            category: "战略 · 不确定性",
            topics: [.uncertainty, .decisions],
            coverAssetName: "cover-riverside",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "一块空地", text: "村庄有一块临河空地。商人想在那里建石仓储粮，渔夫想开码头运货。两个方案都能在今年带来收入。\n\n只是上游正在修水坝，明年水位会升还是降，谁也说不准。石仓一旦建好，就很难再改成码头。"),
                StoryScene(number: 2, title: "先搭木台", text: "一位老人建议今年只搭一座可拆的木台，花费一点钱，也赚得少一些。等水坝完工，再决定建仓还是建码头。\n\n商人反对：“明明有利润，为什么等？”老人说：“等一年，我们会知道河要往哪里走。”"),
                StoryScene(number: 3, title: "水位变了", text: "来年，河水涨得比预想高。石仓原定的位置常被淹到，码头却正好可以停靠大船。\n\n木台拆掉只用了半天。若当初砌了石仓，改建的花费会吃掉好几年的收益。"),
                StoryScene(number: 4, title: "留住选择", text: "村民最终建起码头。老人承认，若水位不变，早建石仓也许能多赚一年。\n\n但他们愿意付出那一点等待的代价，换取看清水位后再选择的自由。有时，暂时不把路走死，本身就有价值。")
            ],
            recallPrompt: "面对不确定的新市场，公司先做可撤回的小试点，等信息更多再决定是否建厂。这保留了什么？",
            choices: [
                StoryChoice(title: "实物期权价值", explanation: "对。小额投入和等待保留了未来根据新信息选择的权利。"),
                StoryChoice(title: "沉没成本", explanation: "沉没成本是已经付出且不可收回的代价；这里关心的是避免过早锁定不可逆投入。"),
                StoryChoice(title: "规模经济", explanation: "规模经济关注扩大产出后单位成本下降，不能说明为何等待和保留选择有价值。")
            ],
            concept: "Real Options",
            conceptChinese: "实物期权价值",
            insight: "在不确定、难回头的决定前，保留选择的能力也有价值。",
            explanation: "当投资难以撤回，且未来会出现有用信息时，等待或先做小规模试验可能带来额外价值。它不是永远拖延，而是比较等待成本与获得信息、避免错误锁定的收益。",
            businessExample: "企业进入陌生市场时，先开试点门店、签短期租约，可以用较小成本了解需求，再决定是否建设大规模配送中心。",
            comparison: "实物期权强调未来可选择的权利；机会成本强调选择一种方案时放弃的最佳替代收益。评估等待仍需计算机会成本。",
            words: [
                StoryWord(term: "Option", origin: "拉丁语 optio", meaning: "未来可以选择、但不必执行的权利"),
                StoryWord(term: "Irreversible", origin: "拉丁语 revertere 前加否定词", meaning: "投入后难以撤回或恢复"),
                StoryWord(term: "Flexibility", origin: "拉丁语 flectere", meaning: "随新情况调整方向的能力")
            ]
        )
    ]
}
