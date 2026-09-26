import Foundation

struct FableStory: Identifiable {
    let id: String
    let title: String
    let teaser: String
    let category: String
    let topics: [StoryTopic]
    let coverAssetName: String
    let readingMinutes: Int
    let scenes: [StoryScene]
    let recallPrompt: String
    let choices: [StoryChoice]
    let concept: String
    let conceptChinese: String
    let insight: String
    let explanation: String
    let businessExample: String
    let comparison: String
    let words: [StoryWord]
}

enum StoryTopic: String, CaseIterable, Codable, Identifiable {
    case systems
    case incentives
    case information
    case uncertainty
    case decisions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .systems: "系统反馈"
        case .incentives: "激励设计"
        case .information: "信息差"
        case .uncertainty: "不确定性"
        case .decisions: "决策方法"
        }
    }

    var symbol: String {
        switch self {
        case .systems: "arrow.triangle.2.circlepath"
        case .incentives: "slider.horizontal.3"
        case .information: "eye"
        case .uncertainty: "waveform.path"
        case .decisions: "point.3.connected.trianglepath.dotted"
        }
    }
}

struct StoryScene: Identifiable {
    let number: Int
    let title: String
    let text: String

    var id: Int { number }
}

struct StoryWord: Identifiable {
    let term: String
    let origin: String
    let meaning: String

    var id: String { term }
}

struct StoryChoice: Identifiable {
    let title: String
    let explanation: String

    var id: String { title }
}

enum StoryCatalog {
    static let stories: [FableStory] = [
        FableStory(
            id: "moving-bakery",
            title: "城门旁的面包店",
            teaser: "一位税官算准了商人的路线，却没算到自己的规则会改变路线。",
            category: "经济学 · 决策",
            topics: [.systems, .decisions],
            coverAssetName: "cover-bakery",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "旧地图", text: "城里只有一座通往集市的东门。每天清晨，送面包的马车都从那里经过。\n\n税官观察了整整一年，发现车流与面包销量之间有一个稳定关系：每多十辆马车，集市大约多卖出一百条面包。"),
                StoryScene(number: 2, title: "新规则", text: "国库缺钱时，税官提出在东门收取通行费。他拿出旧账本预测：马车只会少一点，卖面包的收入依然足够缴税。\n\n城主相信了这张表。通行费从下个月开始执行。"),
                StoryScene(number: 3, title: "消失的马车", text: "税官很快发现，东门的马车比预测少了一半。他以为城里的面包需求突然下降。\n\n可集市里依然飘着新鲜面包的香气。原来，几家面包店搬到了集市旁；还有商人改在夜里从南门送货。"),
                StoryScene(number: 4, title: "账本之外", text: "税官翻遍旧账，仍找不到新的车流规律。老店主指着他的税令说：\n\n“你用旧规则下的路线，预测新规则下的人。可我们看见新规则，也会重新选择。”\n\n税官终于明白：他的表没有算错过去，却不能替改变后的世界作答。")
            ],
            recallPrompt: "公司改了供应商评分规则，还能直接用旧数据预测供应商会怎样报价吗？",
            choices: [
                StoryChoice(title: "卢卡斯批判", explanation: "对。规则改变后，参与者会调整行为，旧数据里的关系可能不再稳定。"),
                StoryChoice(title: "沉没成本", explanation: "沉没成本讨论已经付出且无法收回的代价，不解释规则改变后人们的行为关系。"),
                StoryChoice(title: "规模经济", explanation: "规模经济讨论产量扩大时单位成本如何变化，与这里的政策反应不同。")
            ],
            concept: "Lucas Critique",
            conceptChinese: "卢卡斯批判",
            insight: "改变规则，也会改变人们的决策方式。",
            explanation: "从旧制度下的数据得到的行为关系，未必能用于预测新制度的结果。人们会理解政策、调整预期，并改变自己的选择。",
            businessExample: "如果企业改变供应商评分和分单规则，供应商也会调整报价与交付行为。不能直接用旧评分制度下的数据推断新制度的效果。",
            comparison: "它关注规则改变后行为关系是否仍成立；古德哈特定律更关注指标成为目标后如何失真。",
            words: [
                StoryWord(term: "Critique", origin: "希腊语 kritikos", meaning: "辨别、审视一种推理的前提"),
                StoryWord(term: "Invariant", origin: "拉丁语 in- + variare", meaning: "不随环境改变的关系"),
                StoryWord(term: "Endogenous", origin: "希腊语 endon + genos", meaning: "由系统内部行为产生的")
            ]
        ),
        FableStory(
            id: "sealed-lanterns",
            title: "封好的灯箱",
            teaser: "好灯匠没有变少，却一个接一个离开了市场。",
            category: "信息经济学",
            topics: [.information, .incentives],
            coverAssetName: "cover-lanterns",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "两种灯", text: "海港的灯匠把航灯封在木箱里出售。好灯能在风雨中亮上一整夜，普通灯只能撑到半夜。\n\n灯匠知道自己做的是哪一种，出海的船长却不能当场拆箱试灯。"),
                StoryScene(number: 2, title: "平均价", text: "好灯值十枚银币，普通灯值四枚。船长看不出差别，只肯出七枚。\n\n普通灯匠立刻把灯送来。好灯匠算了算材料和手艺，摇头回家了。"),
                StoryScene(number: 3, title: "越来越暗", text: "第二个月，船长发现买到好灯的机会变小，便把报价降到六枚。又有几位好灯匠退出。\n\n到了冬季，港口几乎买不到能亮整夜的灯。船长抱怨灯匠的手艺退步了。"),
                StoryScene(number: 4, title: "谁留下来", text: "一位老灯匠说：“手艺没有消失。只是你给所有灯同一个价，最值得买的灯反而最先离开。”\n\n船长望着港口的灯火，第一次明白：价格不只反映市场里有什么，也会改变谁愿意留在市场里。")
            ],
            recallPrompt: "买家无法辨别二手设备的质量，统一压价后优质卖家退出。这是什么机制？",
            choices: [
                StoryChoice(title: "道德风险", explanation: "道德风险主要是交易后隐藏行动；这里隐藏的是交易前的商品质量。"),
                StoryChoice(title: "逆向选择", explanation: "对。买家看不清质量，统一价格让优质卖家先退出。"),
                StoryChoice(title: "机会成本", explanation: "机会成本是放弃的最好替代选择的价值，不能解释市场质量为何持续下降。")
            ],
            concept: "Adverse Selection",
            conceptChinese: "逆向选择",
            insight: "无法辨别质量时，统一定价会改变留下来的商品。",
            explanation: "交易前，一方知道自身质量，另一方看不见。买方按平均质量定价，高质量卖方可能退出，使市场平均质量继续下降。",
            businessExample: "采购方若只比较无法验证质量的最低报价，可靠供应商可能退出竞标，留下来的供应商结构也会随之改变。",
            comparison: "逆向选择发生在交易前，隐藏的是类型或质量；道德风险通常发生在交易后，隐藏的是行动。",
            words: [
                StoryWord(term: "Adverse", origin: "拉丁语 adversus", meaning: "朝不利方向发展的"),
                StoryWord(term: "Asymmetry", origin: "希腊语 a- + symmetria", meaning: "不对称；这里指重要信息分布不均"),
                StoryWord(term: "Composition", origin: "拉丁语 com- + ponere", meaning: "群体的组成结构")
            ]
        ),
        FableStory(
            id: "prediction-board",
            title: "预言板上的麦价",
            teaser: "预言家算对了歉收，却没算到人们会读到预言。",
            category: "复杂系统",
            topics: [.systems, .uncertainty],
            coverAssetName: "cover-wheat-price",
            readingMinutes: 3,
            scenes: [
                StoryScene(number: 1, title: "可靠的预言", text: "村里的预言家擅长看云和土壤。过去十年，她都能在收获前猜出麦价的大致方向。\n\n她的记录被钉在镇口的木板上，人人都说这块板比集市上的秤还可靠。"),
                StoryScene(number: 2, title: "即将涨价", text: "一个春天，她写下：“秋天麦价恐怕会大涨。”\n\n磨坊主读后提前囤麦，农夫读后不急着出售。几周内，现货已经涨价。商人见价格上涨，又争相买入。"),
                StoryScene(number: 3, title: "雨后的丰收", text: "夏天接连下了几场好雨，秋收并不差。可预言家发现，价格仍然高得离奇。\n\n有人责怪她预言错误，有人坚持说正因为她预测准确，大家才及早备货。"),
                StoryScene(number: 4, title: "木板也在市场里", text: "预言家将木板翻过来，写下另一句话：\n\n“当人们根据我的话买卖时，我的预言已不是站在市场外的一双眼睛。它也成了市场的一只手。”\n\n从此，她每次预测，都会先问谁会看到它。")
            ],
            recallPrompt: "公开的需求预测让客户提前下单，最终需求又被预测影响。这说明什么？",
            choices: [
                StoryChoice(title: "路径依赖", explanation: "路径依赖强调过去的选择限制后续路径；这里的关键是预测反过来改变被预测的对象。"),
                StoryChoice(title: "反身性", explanation: "对。参与者看到预测后采取行动，预测因此成了系统的一部分。"),
                StoryChoice(title: "边际效用", explanation: "边际效用讨论多消费一单位带来的额外满足，与预测和行为之间的反馈无关。")
            ],
            concept: "Reflexivity",
            conceptChinese: "反身性",
            insight: "对系统的认识，可能反过来改变系统本身。",
            explanation: "当参与者根据某种观察、预测或叙事采取行动时，这些行动会改变被观察的对象。预测因而不能总被看作独立于现实的旁观结果。",
            businessExample: "公开的需求预测会影响供应商备货和客户下单。之后观察到的需求，可能已包含预测发布所引发的行为。",
            comparison: "它强调观察与被观察对象之间的反馈；自我实现预言是其中可能出现的一种结果，并非每次反馈都会让预测成真。",
            words: [
                StoryWord(term: "Reflexivity", origin: "拉丁语 reflectere", meaning: "折返；作用返回到自身"),
                StoryWord(term: "Feedback", origin: "英语 feed + back", meaning: "结果返回并影响下一轮行为"),
                StoryWord(term: "Expectation", origin: "拉丁语 exspectare", meaning: "对未来的预期")
            ]
        )
    ] + additionalStories

    static var today: FableStory {
        let day = Calendar.current.ordinality(of: .day, in: .era, for: .now) ?? 0
        return stories[day % stories.count]
    }
}
