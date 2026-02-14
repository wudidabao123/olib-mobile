import '../models/prescription.dart';

/// AI 服务抽象接口
abstract class AiService {
  Future<ReadingBag> diagnose(String symptoms);
}

/// Mock AI 服务 - 基于预设主题返回精选书单
class MockAiService implements AiService {
  // 预设主题 → 书单映射
  static final Map<String, ReadingBag> _themeResponses = {
    'relax': ReadingBag(
      diagnosis: '你需要给自己的心灵放个假，用文字的力量卸下肩上的重担。',
      tips: [
        ReadingTip(
          bookName: '人间值得',
          author: '中村恒子',
          reason: '一位90岁心理医生的人生智慧，教你用轻松的心态面对压力。',
          category: '治愈',
        ),
        ReadingTip(
          bookName: '蛤蟆先生去看心理医生',
          author: 'Robert de Board',
          reason: '用童话的方式讲述心理疗愈，轻松读完却有深刻启发。',
          category: '治愈',
        ),
        ReadingTip(
          bookName: '当下的力量',
          author: 'Eckhart Tolle',
          reason: '帮助你放下焦虑，活在当下，是全球畅销的减压必读书。',
          category: '心灵',
        ),
      ],
    ),
    'direction': ReadingBag(
      diagnosis: '迷茫是成长的信号。以下三本书会帮你看清前路，找到内心的指南针。',
      tips: [
        ReadingTip(
          bookName: '悉达多',
          author: 'Hermann Hesse',
          reason: '一个人的觉醒之旅，帮你在混沌中找到自己的答案。',
          category: '哲学',
        ),
        ReadingTip(
          bookName: '认知觉醒',
          author: '周岭',
          reason: '解决"知道很多道理却过不好一生"的行动力问题。',
          category: '成长',
        ),
        ReadingTip(
          bookName: '被讨厌的勇气',
          author: '岸见一郎',
          reason: '阿德勒心理学，教你摆脱他人期待，走自己的路。',
          category: '心理',
        ),
      ],
    ),
    'learn': ReadingBag(
      diagnosis: '学习是最好的投资。以下三本书帮你建立底层思维，少走弯路。',
      tips: [
        ReadingTip(
          bookName: '学习之道',
          author: 'Barbara Oakley',
          reason: '脑科学视角揭示高效学习的秘密，适合新手构建学习方法论。',
          category: '学习',
        ),
        ReadingTip(
          bookName: '思考，快与慢',
          author: 'Daniel Kahneman',
          reason: '诺贝尔奖得主的代表作，理解人类思维的两种系统。',
          category: '思维',
        ),
        ReadingTip(
          bookName: '刻意练习',
          author: 'Anders Ericsson',
          reason: '打破"天赋论"，揭示从新手到专家的科学路径。',
          category: '技能',
        ),
      ],
    ),
    'bedtime': ReadingBag(
      diagnosis: '睡前不适合烧脑，这三本陪你轻松入眠，做个好梦。',
      tips: [
        ReadingTip(
          bookName: '小王子',
          author: 'Antoine de Saint-Exupéry',
          reason: '永远的经典，每次重读都会发现新的温柔。',
          category: '文学',
        ),
        ReadingTip(
          bookName: '解忧杂货店',
          author: '东野圭吾',
          reason: '温暖治愈的故事，读完内心平静而满足。',
          category: '小说',
        ),
        ReadingTip(
          bookName: '我的世界观',
          author: 'Albert Einstein',
          reason: '爱因斯坦的随笔集，每篇短小精悍，睡前翻几页刚好。',
          category: '随笔',
        ),
      ],
    ),
    'heal': ReadingBag(
      diagnosis: '每个人都有低落的时刻。这三本书像老朋友一样，陪你安静地坐一会儿。',
      tips: [
        ReadingTip(
          bookName: '也许你该找个人聊聊',
          author: 'Lori Gottlieb',
          reason: '心理治疗师的真实故事，读完会觉得"原来不只是我这样"。',
          category: '治愈',
        ),
        ReadingTip(
          bookName: '活着',
          author: '余华',
          reason: '在苦难中看见生命的韧性，朴素而震撼人心。',
          category: '文学',
        ),
        ReadingTip(
          bookName: '岛上书店',
          author: 'Gabrielle Zevin',
          reason: '"没有谁是一座孤岛"——一本关于爱与重建的温暖小说。',
          category: '小说',
        ),
      ],
    ),
    'thinking': ReadingBag(
      diagnosis: '提升思维就是在升级你的操作系统。这三本经典帮你重新看待世界。',
      tips: [
        ReadingTip(
          bookName: '穷查理宝典',
          author: 'Charlie Munger',
          reason: '巴菲特合伙人的多元思维模型，建立跨学科思维框架。',
          category: '思维',
        ),
        ReadingTip(
          bookName: '原则',
          author: 'Ray Dalio',
          reason: '桥水基金创始人的决策思维体系，适合想系统思考的人。',
          category: '管理',
        ),
        ReadingTip(
          bookName: '黑天鹅',
          author: 'Nassim Nicholas Taleb',
          reason: '颠覆认知的经典，教你拥抱不确定性。',
          category: '思维',
        ),
      ],
    ),
  };

  @override
  Future<ReadingBag> diagnose(String symptoms) async {
    // 模拟 AI 思考延迟
    await Future.delayed(const Duration(seconds: 2));

    // 尝试匹配预设主题
    for (final entry in _themeResponses.entries) {
      if (symptoms == entry.key) {
        return entry.value;
      }
    }

    // 自由输入：根据关键词简单匹配
    final lower = symptoms.toLowerCase();
    
    if (lower.contains('压力') || lower.contains('累') || lower.contains('stress') || lower.contains('relax')) {
      return _themeResponses['relax']!;
    }
    if (lower.contains('迷茫') || lower.contains('方向') || lower.contains('lost') || lower.contains('confused')) {
      return _themeResponses['direction']!;
    }
    if (lower.contains('学习') || lower.contains('learn') || lower.contains('技能') || lower.contains('skill')) {
      return _themeResponses['learn']!;
    }
    if (lower.contains('睡') || lower.contains('sleep') || lower.contains('bedtime') || lower.contains('轻松')) {
      return _themeResponses['bedtime']!;
    }
    if (lower.contains('低落') || lower.contains('伤心') || lower.contains('sad') || lower.contains('heal') || lower.contains('治愈')) {
      return _themeResponses['heal']!;
    }
    if (lower.contains('思维') || lower.contains('认知') || lower.contains('think') || lower.contains('提升')) {
      return _themeResponses['thinking']!;
    }

    // 默认返回 direction 主题
    return _themeResponses['direction']!;
  }
}
