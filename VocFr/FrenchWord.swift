import Foundation
import SwiftData

class FrenchVocabularySeeder {
    
    static func seedAllData(to modelContext: ModelContext) throws {
        let unites = createAllUnites()
        
        for unite in unites {
            modelContext.insert(unite)
        }
        
        // 创建初始用户进度
        let userProgress = UserProgress()
        modelContext.insert(userProgress)
        
        try modelContext.save()
        print("成功导入 \(unites.count) 个单元的数据")
    }
    
    private static func createAllUnites() -> [Unite] {
        return [
            createUnite1(),
            createUnite2(),
            createUnite3()
        ]
    }
    
    // MARK: - Unité 1: À l'école
    
    private static func createUnite1() -> Unite {
        let unite1 = Unite(
            id: "unite1",
            number: 1,
            title: "À l'école",
            isUnlocked: true,
            requiredStars: 0
        )
        
        unite1.sections = [
            createSection1_1(), // à l'école
            createSection1_2(), // les couleurs
            createSection1_3(), // les nombres
            createSection1_4(), // les verbes
            createSection1_5()  // les prépositions
        ]
        
        // 设置关联
        for section in unite1.sections {
            section.unite = unite1
        }
        
        return unite1
    }
    
    private static func createSection1_1() -> Section {
        let section = Section(id: "section1_1", name: "à l'école", orderIndex: 1)
        
        let schoolWords: [(String, String, String, String, String?)] = [
            // 学校用品
            ("bureau", "课桌", "masculine", "school_objects", nil),
            ("table", "桌子", "feminine", "school_objects", nil),
            ("chaise", "椅子", "feminine", "school_objects", nil),
            ("cahier", "练习本", "masculine", "school_objects", nil),
            ("livre", "书", "masculine", "school_objects", nil),
            ("feuille", "纸张", "feminine", "school_objects", nil),
            ("classeur", "文件夹", "masculine", "school_objects", nil),
            ("crayon", "铅笔", "masculine", "school_objects", nil),
            ("gomme", "橡皮", "feminine", "school_objects", nil),
            ("taille-crayon", "卷笔刀", "masculine", "school_objects", nil),
            ("stylo", "钢笔", "masculine", "school_objects", nil),
            ("feutre", "毡笔", "masculine", "school_objects", nil),
            ("colle", "胶水", "feminine", "school_objects", nil),
            ("trousse", "铅笔盒", "feminine", "school_objects", nil),
            ("devoir", "作业", "masculine", "school_objects", nil),
            ("craie", "粉笔", "feminine", "school_objects", nil),
            ("éponge", "海绵", "feminine", "school_objects", "elision"),
            ("sac", "书包", "masculine", "school_objects", nil),
            ("cartable", "书包", "masculine", "school_objects", nil),
            ("tableau", "黑板", "masculine", "school_objects", nil),
            ("ordinateur", "电脑", "masculine", "school_objects", "elision"),
            ("porte", "门", "feminine", "school_objects", nil),
            ("fenêtre", "窗户", "feminine", "school_objects", nil),
            ("salle de classe", "教室", "feminine", "school_objects", nil),
            ("école", "学校", "feminine", "school_objects", "elision"),
            ("image", "图片", "feminine", "school_objects", "elision"),
            ("balle", "球", "feminine", "school_objects", nil),
            ("ballon", "球", "masculine", "school_objects", nil),
            ("enseignante", "女老师", "feminine", "people", "elision"),
            ("enseignant", "男老师", "masculine", "people", "elision"),
            ("fille", "女孩", "feminine", "people", nil),
            ("garçon", "男孩", "masculine", "people", nil)
        ]
        
        section.sectionWords = createSectionWords(from: schoolWords, section: section)
        return section
    }
    
    private static func createSection1_2() -> Section {
        let section = Section(id: "section1_2", name: "les couleurs", orderIndex: 2)
        
        let colorWords: [(String, String, String, String, String?)] = [
            ("vert", "绿色", "adjective", "colors", nil),
            ("jaune", "黄色", "adjective", "colors", nil),
            ("orange", "橙色", "adjective", "colors", nil),
            ("rouge", "红色", "adjective", "colors", nil),
            ("rose", "粉色", "adjective", "colors", nil),
            ("mauve", "淡紫色", "adjective", "colors", nil),
            ("violet", "紫色", "adjective", "colors", nil),
            ("bleu", "蓝色", "adjective", "colors", nil),
            ("brun", "棕色", "adjective", "colors", nil),
            ("gris", "灰色", "adjective", "colors", nil),
            ("noir", "黑色", "adjective", "colors", nil),
            ("blanc", "白色", "adjective", "colors", nil)
        ]
        
        section.sectionWords = createSectionWords(from: colorWords, section: section)
        return section
    }
    
    private static func createSection1_3() -> Section {
        let section = Section(id: "section1_3", name: "les nombres", orderIndex: 3)
        
        let numberWords: [(String, String, String, String, String?)] = [
            ("zéro", "零", "number", "numbers", nil),
            ("un", "一", "number", "numbers", nil),
            ("deux", "二", "number", "numbers", nil),
            ("trois", "三", "number", "numbers", nil),
            ("quatre", "四", "number", "numbers", nil),
            ("cinq", "五", "number", "numbers", nil),
            ("six", "六", "number", "numbers", nil),
            ("sept", "七", "number", "numbers", nil),
            ("huit", "八", "number", "numbers", nil),
            ("neuf", "九", "number", "numbers", nil),
            ("dix", "十", "number", "numbers", nil),
            ("onze", "十一", "number", "numbers", nil),
            ("douze", "十二", "number", "numbers", nil)
        ]
        
        section.sectionWords = createSectionWords(from: numberWords, section: section)
        return section
    }
    
    private static func createSection1_4() -> Section {
        let section = Section(id: "section1_4", name: "les verbes", orderIndex: 4)
        
        let verbWords: [(String, String, String, String, String?)] = [
            ("Je", "我", "pronoun", "pronouns", nil),
            ("tu", "你", "pronoun", "pronouns", nil),
            ("il", "他", "pronoun", "pronouns", nil),
            ("elle", "她", "pronoun", "pronouns", nil),
            ("chercher", "寻找", "verb", "verbs", nil),
            ("dessiner", "画画", "verb", "verbs", nil),
            ("jouer", "玩", "verb", "verbs", nil),
            ("montrer", "展示", "verb", "verbs", nil),
            ("écouter", "听", "verb", "verbs", nil),
            ("coller", "粘贴", "verb", "verbs", nil),
            ("chanter", "唱歌", "verb", "verbs", nil),
            ("trouver", "找到", "verb", "verbs", nil),
            ("fermer", "关闭", "verb", "verbs", nil),
            ("ranger", "整理", "verb", "verbs", nil),
            ("regarder", "看", "verb", "verbs", nil)
        ]
        
        section.sectionWords = createSectionWords(from: verbWords, section: section)
        return section
    }
    
    private static func createSection1_5() -> Section {
        let section = Section(id: "section1_5", name: "les prépositions", orderIndex: 5)
        
        let prepositionWords: [(String, String, String, String, String?)] = [
            ("sur", "在...上面", "preposition", "prepositions", nil),
            ("sous", "在...下面", "preposition", "prepositions", nil),
            ("dans", "在...里面", "preposition", "prepositions", nil),
            ("devant", "在...前面", "preposition", "prepositions", nil),
            ("derrière", "在...后面", "preposition", "prepositions", nil)
        ]
        
        section.sectionWords = createSectionWords(from: prepositionWords, section: section)
        return section
    }
    
    // MARK: - Unité 2: C'est la fête
    
    private static func createUnite2() -> Unite {
        let unite2 = Unite(
            id: "unite2",
            number: 2,
            title: "C'est la fête",
            isUnlocked: false,
            requiredStars: 50
        )
        
        unite2.sections = [
            createSection2_1(), // la famille
            createSection2_2(), // les aliments
            createSection2_3(), // autres vocables
            createSection2_4(), // les verbes
            createSection2_5()  // les nombres jusqu'à 20
        ]
        
        for section in unite2.sections {
            section.unite = unite2
        }
        
        return unite2
    }
    
    private static func createSection2_1() -> Section {
        let section = Section(id: "section2_1", name: "la famille", orderIndex: 1)
        
        let familyWords: [(String, String, String, String, String?)] = [
            ("famille", "家庭", "feminine", "family", nil),
            ("père", "父亲", "masculine", "family", nil),
            ("mère", "母亲", "feminine", "family", nil),
            ("parents", "父母", "plural", "family", nil),
            ("papa", "爸爸", "masculine", "family", nil),
            ("maman", "妈妈", "feminine", "family", nil),
            ("grand-père", "爷爷/外公", "masculine", "family", nil),
            ("grand-mère", "奶奶/外婆", "feminine", "family", nil),
            ("grands-parents", "祖父母/外祖父母", "plural", "family", nil),
            ("papy", "爷爷", "masculine", "family", nil),
            ("mamie", "奶奶", "feminine", "family", nil),
            ("frère", "兄弟", "masculine", "family", nil),
            ("soeur", "姐妹", "feminine", "family", nil),
            ("oncle", "叔叔/舅舅", "masculine", "family", "elision"),
            ("tante", "阿姨/姑姑", "feminine", "family", nil)
        ]
        
        section.sectionWords = createSectionWords(from: familyWords, section: section)
        return section
    }
    
    private static func createSection2_2() -> Section {
        let section = Section(id: "section2_2", name: "les aliments", orderIndex: 2)
        
        let foodWords: [(String, String, String, String, String?)] = [
            ("gâteau", "蛋糕", "masculine", "food", nil),
            ("tarte", "馅饼", "feminine", "food", nil),
            ("glace", "冰淇淋", "feminine", "food", nil),
            ("bonbon", "糖果", "masculine", "food", nil),
            ("chocolat", "巧克力", "masculine", "food", nil),
            ("pain", "面包", "masculine", "food", nil),
            ("baguette", "法式长棍面包", "feminine", "food", nil),
            ("fruits", "水果", "plural", "food", nil),
            ("citron", "柠檬", "masculine", "food", nil),
            ("banane", "香蕉", "feminine", "food", nil),
            ("pomme", "苹果", "feminine", "food", nil),
            ("poire", "梨", "feminine", "food", nil),
            ("fraise", "草莓", "feminine", "food", nil),
            ("orange", "橙子", "feminine", "food", "elision"),
            ("melon", "甜瓜", "masculine", "food", nil),
            ("ananas", "菠萝", "masculine", "food", "elision"),
            ("salade de fruits", "水果沙拉", "feminine", "food", nil),
            ("légumes", "蔬菜", "plural", "food", nil),
            ("poivron", "甜椒", "masculine", "food", nil),
            ("salade", "沙拉", "feminine", "food", nil),
            ("carotte", "胡萝卜", "feminine", "food", nil),
            ("tomate", "西红柿", "feminine", "food", nil),
            ("concombre", "黄瓜", "masculine", "food", nil),
            ("champignon", "蘑菇", "masculine", "food", nil),
            ("pomme de terre", "土豆", "feminine", "food", nil),
            ("fromage", "奶酪", "masculine", "food", nil),
            ("saucisse", "香肠", "feminine", "food", nil),
            ("poisson", "鱼", "masculine", "food", nil),
            ("viande", "肉", "feminine", "food", nil),
            ("boissons", "饮料", "plural", "food", nil),
            ("eau", "水", "feminine", "food", "elision"),
            ("limonade", "柠檬汽水", "feminine", "food", nil),
            ("jus", "果汁", "masculine", "food", nil),
            ("jus d'orange", "橙汁", "masculine", "food", nil),
            ("lait", "牛奶", "masculine", "food", nil),
            ("café", "咖啡", "masculine", "food", nil),
            ("thé", "茶", "masculine", "food", nil),
            ("sucre", "糖", "masculine", "food", nil),
            ("poivre", "胡椒", "masculine", "food", nil),
            ("sel", "盐", "masculine", "food", nil)
        ]
        
        section.sectionWords = createSectionWords(from: foodWords, section: section)
        return section
    }
    
    private static func createSection2_3() -> Section {
        let section = Section(id: "section2_3", name: "autres vocables", orderIndex: 3)
        
        let otherWords: [(String, String, String, String, String?)] = [
            ("fête", "聚会", "feminine", "other", nil),
            ("invitation", "邀请", "feminine", "other", "elision"),
            ("musique", "音乐", "feminine", "other", nil),
            ("il est", "他是", "other", "other", nil),
            ("et", "和", "other", "other", nil)
        ]
        
        section.sectionWords = createSectionWords(from: otherWords, section: section)
        return section
    }
    
    private static func createSection2_4() -> Section {
        let section = Section(id: "section2_4", name: "les verbes", orderIndex: 4)
        
        let verbWords: [(String, String, String, String, String?)] = [
            ("avoir", "有", "verb", "verbs", nil),
            ("aimer", "爱/喜欢", "verb", "verbs", nil),
            ("manger", "吃", "verb", "verbs", nil),
            ("couper", "切", "verb", "verbs", nil),
            ("éplucher", "削皮", "verb", "verbs", nil),
            ("prendre", "拿/取", "verb", "verbs", nil),
            ("mettre", "放/穿", "verb", "verbs", nil)
        ]
        
        section.sectionWords = createSectionWords(from: verbWords, section: section)
        return section
    }
    
    private static func createSection2_5() -> Section {
        let section = Section(id: "section2_5", name: "les nombres jusqu'à 20", orderIndex: 5)
        
        let numberWords: [(String, String, String, String, String?)] = [
            ("zéro", "零", "number", "numbers", nil),
            ("un", "一", "number", "numbers", nil),
            ("deux", "二", "number", "numbers", nil),
            ("trois", "三", "number", "numbers", nil),
            ("quatre", "四", "number", "numbers", nil),
            ("cinq", "五", "number", "numbers", nil),
            ("six", "六", "number", "numbers", nil),
            ("sept", "七", "number", "numbers", nil),
            ("huit", "八", "number", "numbers", nil),
            ("neuf", "九", "number", "numbers", nil),
            ("dix", "十", "number", "numbers", nil),
            ("onze", "十一", "number", "numbers", nil),
            ("douze", "十二", "number", "numbers", nil),
            ("treize", "十三", "number", "numbers", nil),
            ("quatorze", "十四", "number", "numbers", nil),
            ("quinze", "十五", "number", "numbers", nil),
            ("seize", "十六", "number", "numbers", nil),
            ("dix-sept", "十七", "number", "numbers", nil),
            ("dix-huit", "十八", "number", "numbers", nil),
            ("dix-neuf", "十九", "number", "numbers", nil),
            ("vingt", "二十", "number", "numbers", nil)
        ]
        
        section.sectionWords = createSectionWords(from: numberWords, section: section)
        return section
    }
    
    // MARK: - Unité 3: Mon chez-moi
    
    private static func createUnite3() -> Unite {
        let unite3 = Unite(
            id: "unite3",
            number: 3,
            title: "Mon chez-moi",
            isUnlocked: false,
            requiredStars: 100
        )
        
        unite3.sections = [
            createSection3_1(), // la maison
            createSection3_2(), // dans la chambre
            createSection3_3(), // les jouets
            createSection3_4(), // les verbes
            createSection3_5()  // les prépositions
        ]
        
        for section in unite3.sections {
            section.unite = unite3
        }
        
        return unite3
    }
    
    private static func createSection3_1() -> Section {
        let section = Section(id: "section3_1", name: "la maison", orderIndex: 1)
        
        let houseWords: [(String, String, String, String, String?)] = [
            ("maison", "房子", "feminine", "house", nil),
            ("chambre", "房间", "feminine", "house", nil),
            ("salle de bain", "浴室", "feminine", "house", nil),
            ("salon", "客厅", "masculine", "house", nil),
            ("cuisine", "厨房", "feminine", "house", nil),
            ("grenier", "阁楼", "masculine", "house", nil),
            ("cave", "地下室", "feminine", "house", nil),
            ("balcon", "阳台", "masculine", "house", nil),
            ("garage", "车库", "masculine", "house", nil),
            ("terrasse", "露台", "feminine", "house", nil),
            ("jardin", "花园", "masculine", "house", nil),
            ("escalier", "楼梯", "masculine", "house", "elision")
        ]
        
        section.sectionWords = createSectionWords(from: houseWords, section: section)
        return section
    }
    
    private static func createSection3_2() -> Section {
        let section = Section(id: "section3_2", name: "dans la chambre", orderIndex: 2)
        
        let roomWords: [(String, String, String, String, String?)] = [
            ("chaise", "椅子", "feminine", "furniture", nil), // 复用
            ("bureau", "书桌", "masculine", "furniture", nil), // 复用
            ("tapis", "地毯", "masculine", "furniture", nil),
            ("lit", "床", "masculine", "furniture", nil),
            ("armoire", "衣柜", "feminine", "furniture", "elision"),
            ("tiroir", "抽屉", "masculine", "furniture", nil),
            ("miroir", "镜子", "masculine", "furniture", nil),
            ("lampe", "灯", "feminine", "furniture", nil),
            ("boite", "盒子", "feminine", "furniture", nil),
            ("étagère", "架子", "feminine", "furniture", "elision"),
            ("ordinateur", "电脑", "masculine", "furniture", "elision"), // 复用
            ("vêtements", "衣服", "plural", "furniture", nil),
            ("jouets", "玩具", "plural", "furniture", nil),
            ("affaires de classe", "学习用品", "plural", "furniture", nil),
            ("porte", "门", "feminine", "furniture", nil), // 复用
            ("fenêtre", "窗户", "feminine", "furniture", nil) // 复用
        ]
        
        section.sectionWords = createSectionWords(from: roomWords, section: section)
        return section
    }
    
    private static func createSection3_3() -> Section {
        let section = Section(id: "section3_3", name: "les jouets", orderIndex: 3)
        
        let toyWords: [(String, String, String, String, String?)] = [
            ("jeu de cartes", "纸牌游戏", "masculine", "toys", nil),
            ("guitare", "吉他", "feminine", "toys", nil),
            ("roi", "国王", "masculine", "toys", nil),
            ("poisson", "鱼", "masculine", "toys", nil), // 复用，但在玩具上下文中
            ("nounours", "泰迪熊", "masculine", "toys", nil),
            ("peluche", "毛绒玩具", "feminine", "toys", nil),
            ("poupée", "娃娃", "feminine", "toys", nil),
            ("ballon", "球", "masculine", "toys", nil), // 复用
            ("balle", "球", "feminine", "toys", nil), // 复用
            ("dé", "骰子", "masculine", "toys", nil),
            ("moto", "摩托车", "feminine", "toys", nil),
            ("vélo", "自行车", "masculine", "toys", nil),
            ("voiture", "汽车", "feminine", "toys", nil),
            ("tente", "帐篷", "feminine", "toys", nil)
        ]
        
        section.sectionWords = createSectionWords(from: toyWords, section: section)
        return section
    }
    
    private static func createSection3_4() -> Section {
        let section = Section(id: "section3_4", name: "les verbes", orderIndex: 4)
        
        let verbWords: [(String, String, String, String, String?)] = [
            ("avoir", "有", "verb", "verbs", nil), // 复用
            ("être", "是", "verb", "verbs", nil),
            ("aimer", "爱/喜欢", "verb", "verbs", nil), // 复用
            ("manger", "吃", "verb", "verbs", nil), // 复用
            ("couper", "切", "verb", "verbs", nil), // 复用
            ("éplucher", "削皮", "verb", "verbs", nil), // 复用
            ("chercher", "寻找", "verb", "verbs", nil), // 复用
            ("trouver", "找到", "verb", "verbs", nil), // 复用
            ("ranger", "整理", "verb", "verbs", nil), // 复用
            ("jouer", "玩", "verb", "verbs", nil), // 复用
            ("dessiner", "画画", "verb", "verbs", nil), // 复用
            ("chanter", "唱歌", "verb", "verbs", nil), // 复用
            ("danser", "跳舞", "verb", "verbs", nil),
            ("prendre", "拿/取", "verb", "verbs", nil), // 复用
            ("mettre", "放/穿", "verb", "verbs", nil) // 复用
        ]
        
        section.sectionWords = createSectionWords(from: verbWords, section: section)
        return section
    }
    
    private static func createSection3_5() -> Section {
        let section = Section(id: "section3_5", name: "les prépositions", orderIndex: 5)
        
        let prepositionWords: [(String, String, String, String, String?)] = [
            ("sur", "在...上面", "preposition", "prepositions", nil), // 复用
            ("sous", "在...下面", "preposition", "prepositions", nil), // 复用
            ("dans", "在...里面", "preposition", "prepositions", nil), // 复用
            ("devant", "在...前面", "preposition", "prepositions", nil), // 复用
            ("derrière", "在...后面", "preposition", "prepositions", nil), // 复用
            ("à côté de", "在...旁边", "preposition", "prepositions", nil)
        ]
        
        section.sectionWords = createSectionWords(from: prepositionWords, section: section)
        return section
    }
    
    // MARK: - 辅助方法
    
    private static func createSectionWords(from wordData: [(String, String, String, String, String?)], section: Section) -> [SectionWord] {
        var sectionWords: [SectionWord] = []
        var existingWords: [String: Word] = [:] // 用于复用已创建的单词
        
        for (index, wordTuple) in wordData.enumerated() {
            let canonical = wordTuple.0
            let chinese = wordTuple.1
            let genderOrPos = wordTuple.2
            let category = wordTuple.3
            let specialForm = wordTuple.4
            
            // 检查是否已经存在该单词
            let word: Word
            if let existingWord = existingWords[canonical] {
                word = existingWord
            } else {
                word = createWord(
                    canonical: canonical,
                    chinese: chinese,
                    genderOrPos: genderOrPos,
                    category: category,
                    specialForm: specialForm
                )
                existingWords[canonical] = word
            }
            
            let sectionWord = SectionWord(orderIndex: index + 1)
            sectionWord.word = word
            sectionWord.section = section
            sectionWords.append(sectionWord)
        }
        
        return sectionWords
    }
    
    // MARK: - Image Name Mapping
    
    /// Maps canonical word forms to actual asset image names
    private static func mapToAssetImageName(canonical: String, genderOrPos: String) -> String {
        // Handle special cases where asset names don't follow the standard pattern
        let assetNameMappings: [String: String] = [
            // Example mappings - update these based on your actual asset names
            "bureau": "un_bureau",
            "table": "une_table", 
            "chaise": "une_chaise",
            "livre": "un_livre",
            "cahier": "un_cahier",
            "feuille": "une_feuille",
            "crayon": "un_crayon",
            "stylo": "un_stylo",
            "porte": "une_porte",
            "fenêtre": "une_fenetre",
            "école": "une_ecole",
            // Add more mappings as needed based on your actual asset names
        ]
        
        // Check if there's a specific mapping for this word
        if let mappedName = assetNameMappings[canonical] {
            return mappedName
        }
        
        // For words that follow patterns, try different conventions
        // First check if the simple name (without _image suffix) exists
        if Bundle.main.url(forResource: canonical, withExtension: nil) != nil {
            return canonical
        }
        
        // Try with articles based on gender
        if genderOrPos == "masculine" {
            let withArticle = "un_\(canonical)"
            if Bundle.main.url(forResource: withArticle, withExtension: nil) != nil {
                return withArticle
            }
        } else if genderOrPos == "feminine" {
            let withArticle = "une_\(canonical)"
            if Bundle.main.url(forResource: withArticle, withExtension: nil) != nil {
                return withArticle
            }
        }
        
        // Fall back to the original naming convention
        return "\(canonical)_image"
    }
    
    private static func createWord(canonical: String, chinese: String, genderOrPos: String, category: String, specialForm: String?) -> Word {
        let partOfSpeech = getPartOfSpeech(from: genderOrPos)
        
        let word = Word(
            id: canonical,
            canonical: canonical,
            chinese: chinese,
            imageName: mapToAssetImageName(canonical: canonical, genderOrPos: genderOrPos),
            partOfSpeech: partOfSpeech,
            category: category
        )
        
        // 创建单词形式
        word.forms = createWordForms(
            canonical: canonical,
            genderOrPos: genderOrPos,
            specialForm: specialForm
        )
        
        return word
    }
    
    private static func createWordForms(canonical: String, genderOrPos: String, specialForm: String?) -> [WordForm] {
        var forms: [WordForm] = []
        
        switch genderOrPos {
        case "masculine":
            if specialForm == "elision" {
                // l'ordinateur, l'oncle
                forms.append(WordForm(
                    formType: .withElision,
                    french: "l'\(canonical)",
                    articleOnly: "l'",
                    gender: .masculine,
                    number: .singular,
                    isMainForm: true
                ))
                forms.append(WordForm(
                    formType: .definiteArticle,
                    french: "le \(canonical)",
                    articleOnly: "le",
                    gender: .masculine,
                    number: .singular
                ))
            } else {
                forms.append(WordForm(
                    formType: .indefiniteArticle,
                    french: "un \(canonical)",
                    articleOnly: "un",
                    gender: .masculine,
                    number: .singular,
                    isMainForm: true
                ))
                forms.append(WordForm(
                    formType: .definiteArticle,
                    french: "le \(canonical)",
                    articleOnly: "le",
                    gender: .masculine,
                    number: .singular
                ))
            }
            
        case "feminine":
            if specialForm == "elision" {
                // l'école, l'image
                forms.append(WordForm(
                    formType: .withElision,
                    french: "l'\(canonical)",
                    articleOnly: "l'",
                    gender: .feminine,
                    number: .singular,
                    isMainForm: true
                ))
                forms.append(WordForm(
                    formType: .definiteArticle,
                    french: "la \(canonical)",
                    articleOnly: "la",
                    gender: .feminine,
                    number: .singular
                ))
            } else {
                forms.append(WordForm(
                    formType: .indefiniteArticle,
                    french: "une \(canonical)",
                    articleOnly: "une",
                    gender: .feminine,
                    number: .singular,
                    isMainForm: true
                ))
                forms.append(WordForm(
                    formType: .definiteArticle,
                    french: "la \(canonical)",
                    articleOnly: "la",
                    gender: .feminine,
                    number: .singular
                ))
            }
            
        case "plural":
            forms.append(WordForm(
                formType: .indefiniteArticle,
                french: "des \(canonical)",
                articleOnly: "des",
                number: .plural,
                isMainForm: true
            ))
            forms.append(WordForm(
                formType: .definiteArticle,
                french: "les \(canonical)",
                articleOnly: "les",
                number: .plural
            ))
            
        default:
            // 动词、形容词、代词等
            forms.append(WordForm(
                formType: .baseForm,
                french: canonical,
                isMainForm: true
            ))
        }
        
        return forms
    }
    
    static func getPartOfSpeech(from genderOrPos: String) -> PartOfSpeech {
        switch genderOrPos {
        case "masculine", "feminine", "plural":
            return .noun
        case "verb":
            return .verb
        case "adjective":
            return .adjective
        case "number":
            return .number
        case "pronoun":
            return .pronoun
        case "preposition":
            return .preposition
        default:
            return .other
        }
    }
    
    // MARK: - 音频时间戳导入（基于您提供的时间戳文件）
    
    static func addAudioTimestamps(to modelContext: ModelContext) {
        let audioFile = AudioFile(
            fileName: "unite1_audio.mp3",
            filePath: "unite1_audio",
            duration: 120.0 // 根据实际音频长度
        )
        modelContext.insert(audioFile)
        
        let timestampData = parseAudioTimestamps()
        
        for (wordId, formType, startTime, endTime) in timestampData {
            if let word = getWord(by: wordId, from: modelContext) {
                let segment = AudioSegment(
                    startTime: startTime,
                    endTime: endTime,
                    formType: formType,
                    quality: .normal,
                    confidence: 0.9
                )
                segment.word = word
                segment.audioFile = audioFile
                
                modelContext.insert(segment)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("保存音频时间戳时出错: \(error)")
        }
    }
    
    private static func parseAudioTimestamps() -> [(String, WordFormType, Double, Double)] {
        // 基于您提供的时间戳文件解析
        let timestampData: [(String, WordFormType, Double, Double)] = [
            ("bureau", .indefiniteArticle, 0.0, 1.2),
            ("table", .indefiniteArticle, 1.2, 2.6),
            ("chaise", .indefiniteArticle, 2.6, 4.1),
            ("cahier", .indefiniteArticle, 4.1, 5.35),
            ("classeur", .indefiniteArticle, 5.35, 6.888),
            ("crayon", .indefiniteArticle, 6.888, 8.2),
            ("livre", .indefiniteArticle, 8.2, 9.4),
            ("feuille", .indefiniteArticle, 9.4, 10.7),
            ("feutre", .indefiniteArticle, 10.7, 12.0),
            ("stylo", .indefiniteArticle, 12.0, 13.2),
            ("taille-crayon", .indefiniteArticle, 13.2, 14.8),
            ("gomme", .indefiniteArticle, 14.8, 16.0),
            ("devoir", .indefiniteArticle, 16.0, 17.324),
            ("colle", .indefiniteArticle, 17.324, 18.429),
            ("craie", .indefiniteArticle, 18.429, 19.59),
            ("trousse", .indefiniteArticle, 19.59, 20.92),
            ("éponge", .withElision, 20.92, 22.2),
            ("sac", .indefiniteArticle, 22.2, 23.4),
            ("cartable", .indefiniteArticle, 23.4, 24.9),
            ("tableau", .indefiniteArticle, 24.9, 26.1),
            ("ordinateur", .indefiniteArticle, 26.1, 27.75),
            ("porte", .indefiniteArticle, 27.75, 29.1),
            ("fenêtre", .indefiniteArticle, 29.1, 31.0),
            ("salle de classe", .indefiniteArticle, 31.0, 32.375),
            ("école", .withElision, 32.375, 33.7),
            ("image", .withElision, 33.7, 35.1),
            ("balle", .indefiniteArticle, 35.1, 36.2),
            ("ballon", .indefiniteArticle, 36.2, 37.4),
            ("enseignante", .withElision, 37.4, 38.9),
            ("enseignant", .indefiniteArticle, 38.9, 40.4),
            ("fille", .indefiniteArticle, 40.4, 41.6),
            ("garçon", .indefiniteArticle, 41.6, 42.765),
            
            // 颜色
            ("vert", .baseForm, 42.765, 44.293),
            ("jaune", .baseForm, 44.293, 45.052),
            ("orange", .baseForm, 45.052, 46.173),
            ("rouge", .baseForm, 46.173, 47.52),
            ("rose", .baseForm, 47.52, 48.299),
            ("mauve", .baseForm, 48.299, 49.387),
            ("violet", .baseForm, 49.387, 50.5),
            ("bleu", .baseForm, 50.5, 51.5),
            ("brun", .baseForm, 51.5, 52.5),
            ("gris", .baseForm, 52.5, 53.5),
            ("noir", .baseForm, 53.5, 54.6),
            ("blanc", .baseForm, 54.6, 55.75),
            
            // 数字
            ("zéro", .baseForm, 55.75, 56.954),
            ("un", .baseForm, 56.954, 57.524),
            ("deux", .baseForm, 57.524, 58.551),
            ("trois", .baseForm, 58.551, 59.4),
            ("quatre", .baseForm, 59.4, 60.35),
            ("cinq", .baseForm, 60.35, 61.4),
            ("six", .baseForm, 61.4, 62.4),
            ("sept", .baseForm, 62.4, 63.35),
            ("huit", .baseForm, 63.35, 64.15),
            ("neuf", .baseForm, 64.15, 64.952),
            ("dix", .baseForm, 64.952, 65.95),
            ("onze", .baseForm, 65.95, 66.8),
            ("douze", .baseForm, 66.8, 67.9),
            
            // 代词和动词
            ("Je", .baseForm, 67.9, 68.8),
            ("tu", .baseForm, 68.8, 69.527),
            ("il", .baseForm, 69.527, 70.343),
            ("elle", .baseForm, 70.344, 71.233),
            ("chercher", .baseForm, 71.233, 72.296),
            ("dessiner", .baseForm, 72.296, 73.575),
            ("jouer", .baseForm, 73.576, 74.495),
            ("montrer", .baseForm, 74.496, 75.611),
            ("écouter", .baseForm, 75.612, 76.808),
            ("coller", .baseForm, 76.809, 77.65),
            ("chanter", .baseForm, 77.65, 78.65),
            ("trouver", .baseForm, 78.65, 79.75),
            ("fermer", .baseForm, 79.75, 80.9),
            ("ranger", .baseForm, 80.9, 82.0),
            ("regarder", .baseForm, 82.0, 83.25),
            
            // 介词
            ("sur", .baseForm, 83.25, 84.2),
            ("sous", .baseForm, 84.2, 85.0),
            ("dans", .baseForm, 85.0, 85.92),
            ("devant", .baseForm, 85.92, 86.85),
            ("derrière", .baseForm, 86.85, 88.125),
            
            // Unit 2 家庭成员
            ("famille", .indefiniteArticle, 88.125, 89.45),
            ("père", .indefiniteArticle, 89.45, 90.5),
            ("mère", .indefiniteArticle, 90.5, 91.7),
            ("parents", .indefiniteArticle, 91.7, 92.9),
            ("papa", .baseForm, 92.9, 93.9),
            ("maman", .baseForm, 93.9, 94.712),
            ("grand-père", .indefiniteArticle, 94.712, 96.1),
            ("grand-mère", .indefiniteArticle, 96.1, 97.5),
            ("grands-parents", .indefiniteArticle, 97.5, 98.9),
            ("mamie", .baseForm, 98.9, 99.8),
            ("papy", .baseForm, 99.8, 100.8),
            ("frère", .indefiniteArticle, 100.8, 102.0),
            ("soeur", .indefiniteArticle, 102.0, 103.1),
            ("oncle", .indefiniteArticle, 103.1, 104.229),
            ("tante", .indefiniteArticle, 104.229, 105.5)
        ]
        
        return timestampData
    }
    
    private static func getWord(by id: String, from modelContext: ModelContext) -> Word? {
        let descriptor = FetchDescriptor<Word>(
            predicate: #Predicate<Word> { word in word.id == id }
        )
        return try? modelContext.fetch(descriptor).first
    }
}

// MARK: - 数据验证和报告

extension FrenchVocabularySeeder {
    
    static func generateDataReport(from modelContext: ModelContext) -> String {
        let uniteDescriptor = FetchDescriptor<Unite>()
        let wordDescriptor = FetchDescriptor<Word>()
        let audioDescriptor = FetchDescriptor<AudioSegment>()
        
        guard let unites = try? modelContext.fetch(uniteDescriptor),
              let words = try? modelContext.fetch(wordDescriptor),
              let audioSegments = try? modelContext.fetch(audioDescriptor) else {
            return "数据获取失败"
        }
        
        var report = "法语学习数据报告\n"
        report += "==================\n\n"
        
        // 整体统计
        report += "整体统计:\n"
        report += "- 总单元数: \(unites.count)\n"
        report += "- 总单词数: \(words.count)\n"
        report += "- 有音频的单词: \(Set(audioSegments.compactMap { $0.word?.id }).count)\n"
        report += "- 音频片段总数: \(audioSegments.count)\n\n"
        
        // 按单元统计
        for unite in unites.sorted(by: { $0.number < $1.number }) {
            report += "Unité \(unite.number): \(unite.title)\n"
            report += "- 解锁状态: \(unite.isUnlocked ? "已解锁" : "锁定")\n"
            report += "- 所需星星: \(unite.requiredStars)\n"
            report += "- Section数量: \(unite.sections.count)\n"
            
            var totalWordsInUnite = 0
            for section in unite.sections.sorted(by: { $0.orderIndex < $1.orderIndex }) {
                let wordCount = section.sectionWords.count
                totalWordsInUnite += wordCount
                report += "  - \(section.name): \(wordCount) 个单词\n"
            }
            report += "- 单元总单词数: \(totalWordsInUnite)\n\n"
        }
        
        // 词性分布
        let partOfSpeechCounts = Dictionary(grouping: words, by: { $0.partOfSpeech })
            .mapValues { $0.count }
        
        report += "词性分布:\n"
        for (pos, count) in partOfSpeechCounts.sorted(by: { $0.value > $1.value }) {
            report += "- \(pos.rawValue): \(count) 个\n"
        }
        report += "\n"
        
        // 音频覆盖率
        let wordsWithAudio = Set(audioSegments.compactMap { $0.word?.id })
        let coverage = Double(wordsWithAudio.count) / Double(words.count) * 100
        
        report += "音频覆盖率: \(String(format: "%.1f", coverage))%\n"
        report += "缺少音频的单词数: \(words.count - wordsWithAudio.count)\n\n"
        
        // 单词复用情况
        let wordUsageCounts = Dictionary(grouping: words, by: { $0.id })
            .compactMapValues { wordGroup -> Int? in
                guard let word = wordGroup.first else { return nil }
                return word.sectionWords.count
            }
        
        let reusedWords = wordUsageCounts.filter { $0.value > 1 }
        report += "单词复用情况:\n"
        report += "- 复用的单词数: \(reusedWords.count)\n"
        for (wordId, usageCount) in reusedWords.sorted(by: { $0.value > $1.value }).prefix(10) {
            report += "  - \(wordId): 出现在 \(usageCount) 个section中\n"
        }
        
        return report
    }
    
    static func validateData(from modelContext: ModelContext) -> [String] {
        var issues: [String] = []
        
        let wordDescriptor = FetchDescriptor<Word>()
        guard let words = try? modelContext.fetch(wordDescriptor) else {
            issues.append("无法获取单词数据")
            return issues
        }
        
        // 检查单词是否有对应的图片资源
        for word in words {
            let hasImageResource = Bundle.main.url(forResource: word.imageName, withExtension: nil) != nil ||
                                  Bundle.main.url(forResource: word.imageName, withExtension: "png") != nil ||
                                  Bundle.main.url(forResource: word.imageName, withExtension: "jpg") != nil ||
                                  Bundle.main.url(forResource: word.imageName, withExtension: "jpeg") != nil
            
            if !hasImageResource {
                issues.append("缺少图片资源: \(word.imageName) (单词: \(word.canonical))")
            }
        }
        
        // 检查名词是否有正确的性别信息
        let nouns = words.filter { $0.partOfSpeech == .noun }
        for noun in nouns {
            let hasGenderInfo = noun.forms.contains { form in
                form.gender != nil && (form.formType == .indefiniteArticle || form.formType == .definiteArticle)
            }
            if !hasGenderInfo {
                issues.append("名词缺少性别信息: \(noun.canonical)")
            }
        }
        
        // 检查是否有重复的单词ID
        let wordIds = words.map { $0.id }
        let uniqueIds = Set(wordIds)
        if wordIds.count != uniqueIds.count {
            issues.append("存在重复的单词ID")
        }
        
        return issues
    }
    
    /// 生成所有必需图片名称的清单
    static func generateRequiredImageList() -> [String] {
        var allImageNames: [String] = []
        
        // Unite 1 words
        let unite1Words = [
            // School objects
            "bureau_image", "table_image", "chaise_image", "cahier_image", "livre_image", "feuille_image",
            "classeur_image", "crayon_image", "gomme_image", "taille-crayon_image", "stylo_image", "feutre_image",
            "colle_image", "trousse_image", "devoir_image", "craie_image", "éponge_image", "sac_image",
            "cartable_image", "tableau_image", "ordinateur_image", "porte_image", "fenêtre_image",
            "salle de classe_image", "école_image", "image_image", "balle_image", "ballon_image",
            // People
            "enseignante_image", "enseignant_image", "fille_image", "garçon_image",
            // Colors
            "vert_image", "jaune_image", "orange_image", "rouge_image", "rose_image", "mauve_image",
            "violet_image", "bleu_image", "brun_image", "gris_image", "noir_image", "blanc_image",
            // Numbers
            "zéro_image", "un_image", "deux_image", "trois_image", "quatre_image", "cinq_image",
            "six_image", "sept_image", "huit_image", "neuf_image", "dix_image", "onze_image", "douze_image",
            // Pronouns & Verbs
            "Je_image", "tu_image", "il_image", "elle_image", "chercher_image", "dessiner_image",
            "jouer_image", "montrer_image", "écouter_image", "coller_image", "chanter_image",
            "trouver_image", "fermer_image", "ranger_image", "regarder_image",
            // Prepositions
            "sur_image", "sous_image", "dans_image", "devant_image", "derrière_image"
        ]
        
        let unite2Words = [
            // Family
            "famille_image", "père_image", "mère_image", "parents_image", "papa_image", "maman_image",
            "grand-père_image", "grand-mère_image", "grands-parents_image", "papy_image", "mamie_image",
            "frère_image", "soeur_image", "oncle_image", "tante_image",
            // Food
            "gâteau_image", "tarte_image", "glace_image", "bonbon_image", "chocolat_image", "pain_image",
            "baguette_image", "fruits_image", "citron_image", "banane_image", "pomme_image", "poire_image",
            "fraise_image", "melon_image", "ananas_image", "salade de fruits_image", "légumes_image",
            "poivron_image", "salade_image", "carotte_image", "tomate_image", "concombre_image",
            "champignon_image", "pomme de terre_image", "fromage_image", "saucisse_image", "poisson_image",
            "viande_image", "boissons_image", "eau_image", "limonade_image", "jus_image", "jus d'orange_image",
            "lait_image", "café_image", "thé_image", "sucre_image", "poivre_image", "sel_image",
            // Other
            "fête_image", "invitation_image", "musique_image", "il est_image", "et_image",
            // Verbs
            "avoir_image", "aimer_image", "manger_image", "couper_image", "éplucher_image", "prendre_image", "mettre_image",
            // Numbers 13-21
            "treize_image", "quatorze_image", "quinze_image", "seize_image", "dix-sept_image",
            "dix-huit_image", "dix-neuf_image", "vingt_image"
        ]
        
        let unite3Words = [
            // House
            "maison_image", "chambre_image", "salle de bain_image", "salon_image", "cuisine_image",
            "grenier_image", "cave_image", "balcon_image", "garage_image", "terrasse_image",
            "jardin_image", "escalier_image",
            // Furniture
            "tapis_image", "lit_image", "armoire_image", "tiroir_image", "miroir_image", "lampe_image",
            "boite_image", "étagère_image", "vêtements_image", "jouets_image", "affaires de classe_image",
            // Toys
            "jeu de cartes_image", "guitare_image", "roi_image", "nounours_image", "peluche_image",
            "poupée_image", "dé_image", "moto_image", "vélo_image", "voiture_image", "tente_image",
            // Additional verbs
            "être_image", "danser_image",
            // Additional prepositions
            "à côté de_image"
        ]
        
        allImageNames.append(contentsOf: unite1Words)
        allImageNames.append(contentsOf: unite2Words) 
        allImageNames.append(contentsOf: unite3Words)
        
        // Remove duplicates and sort
        return Array(Set(allImageNames)).sorted()
    }
    
    /// 检查Assets中的图片完整性
    static func validateImageAssets() -> String {
        let requiredImages = generateRequiredImageList()
        var report = "图片资源检查报告\n"
        report += "==================\n\n"
        
        var missingImages: [String] = []
        var foundImages: [String] = []
        
        for imageName in requiredImages {
            let hasImage = Bundle.main.url(forResource: imageName, withExtension: nil) != nil ||
                          Bundle.main.url(forResource: imageName, withExtension: "png") != nil ||
                          Bundle.main.url(forResource: imageName, withExtension: "jpg") != nil ||
                          Bundle.main.url(forResource: imageName, withExtension: "jpeg") != nil
            
            if hasImage {
                foundImages.append(imageName)
            } else {
                missingImages.append(imageName)
            }
        }
        
        report += "总需要图片数量: \(requiredImages.count)\n"
        report += "已找到图片数量: \(foundImages.count)\n"
        report += "缺失图片数量: \(missingImages.count)\n\n"
        
        if !missingImages.isEmpty {
            report += "缺失的图片:\n"
            report += "============\n"
            for imageName in missingImages {
                report += "❌ \(imageName)\n"
            }
            report += "\n"
        }
        
        if !foundImages.isEmpty {
            report += "已找到的图片 (前20个):\n"
            report += "==================\n"
            for imageName in foundImages.prefix(20) {
                report += "✅ \(imageName)\n"
            }
            if foundImages.count > 20 {
                report += "... 还有 \(foundImages.count - 20) 个图片\n"
            }
        }
        
        return report
    }
}

// MARK: - 使用示例

/*
// 在App启动时导入数据:

@main
struct PetitFrancaisApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Unite.self, Section.self, Word.self, WordForm.self,
                                     AudioFile.self, AudioSegment.self, UserProgress.self,
                                     WordProgress.self, PracticeRecord.self, SectionWord.self]) { result in
                    switch result {
                    case .success(let container):
                        // 检查是否已有数据
                        let context = container.mainContext
                        let descriptor = FetchDescriptor<Unite>()
                        
                        if (try? context.fetch(descriptor).isEmpty) == true {
                            // 首次启动，导入数据
                            try? FrenchVocabularySeeder.seedAllData(to: context)
                            FrenchVocabularySeeder.addAudioTimestamps(to: context)
                            
                            print("数据导入完成")
                            print(FrenchVocabularySeeder.generateDataReport(from: context))
                            
                            let issues = FrenchVocabularySeeder.validateData(from: context)
                            if !issues.isEmpty {
                                print("数据验证发现问题:")
                                for issue in issues {
                                    print("- \(issue)")
                                }
                            }
                        }
                    case .failure(let error):
                        print("模型容器创建失败: \(error)")
                    }
                }
        }
    }
}
*/
