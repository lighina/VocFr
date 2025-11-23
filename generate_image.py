import base64
from openai import OpenAI

client = OpenAI(api_key="YOUR_API_KEY_HERE")

# ① 固定风格模板（你可以根据需要再微调）
STYLE_TEMPLATE = """
Studio Ghibli–inspired watercolor illustration, soft warm tones, gentle shading, tender hand-painted feeling.
Characters/objects with volume, subtle shadows and rounded shapes.
Cute, warm, child-friendly.
Transparent background ONLY, no paper texture, no gradient, no halo, no colored glow, no vignette, no noise.
The object or character is perfectly centered in a 512×512 canvas, with clean margins and no cropping of limbs, hair or props.
No text, no handwriting, no letters inside the image.
"""

def build_scene_description(french_word: str, pos: str = "", hint_zh: str = "") -> str:
    """
    使用 GPT 文本模型，为某个法语单词生成一段英文场景描述。
    french_word: 法语单词，如 "danser"
    pos: 词性描述，如 "verb", "noun (object)", "noun (person)"
    hint_zh: 中文解释，可选，用来帮模型理解单词含义
    """
    sys_msg = (
        "You are a prompt designer for child-friendly educational illustrations.\n"
        "For each French vocabulary word, you will create a short English description "
        "of a simple scene that clearly shows the meaning of the word.\n\n"
        "Requirements:\n"
        "- 1–2 short sentences in English.\n"
        "- Very concrete and visual.\n"
        "- Only describe what should be drawn, no camera words, no style words.\n"
        "- No text, no labels, no words inside the image.\n"
        "- Suitable for primary school children.\n"
        "- Keep the number of characters small (1–2 people at most).\n"
        "- If it is a verb, show a character performing the action.\n"
        "- If it is a noun, draw the object clearly and simply.\n"
        "Return only the English description."
    )

    user_msg = f"French word: '{french_word}'."
    if pos:
        user_msg += f" Part of speech: {pos}."
    if hint_zh:
        user_msg += f" Chinese hint: {hint_zh}."
    user_msg += " Please describe a simple scene that shows this meaning."

    completion = client.responses.create(
        model="gpt-4.1-mini",
        input=[
            {
                "role": "system",
                "content": sys_msg,
            },
            {
                "role": "user",
                "content": user_msg,
            },
        ],
        max_output_tokens=120,
    )

    scene = completion.output[0].content[0].text.strip()
    return scene

def build_final_prompt(scene_description: str) -> str:
    """
    把固定风格模板 + GPT 生成的场景描述 拼成最终画图 prompt
    """
    return STYLE_TEMPLATE.strip() + "\n\nScene: " + scene_description.strip()

def generate_image_for_word(french_word: str, pos: str = "", hint_zh: str = "") -> None:
    """
    从法语单词到图片：生成 prompt → 调用 Images API → 保存 PNG 文件
    """
    # 1) 得到场景描述
    scene = build_scene_description(french_word, pos=pos, hint_zh=hint_zh)
    print(f"[SCENE for {french_word}]: {scene}")

    # 2) 拼接最终 prompt
    final_prompt = build_final_prompt(scene)
    print(f"[PROMPT]: {final_prompt}")

    # 3) 调用图片模型
    img_response = client.images.generate(
        model="gpt-image-1",
        prompt=final_prompt,
        size="512x512",            # 你的需求尺寸
        quality="hd",              # 或者 "standard" 视情况
        n=1,
        # 注意：透明背景在最新 API 中通常默认支持 PNG alpha，
        # 如果将来有专门的 transparent_background 参数，也可以在这里加。
    )

    image_base64 = img_response.data[0].b64_json

    # 4) 保存为 PNG 文件（带透明背景）
    filename = f"{french_word.replace(' ', '_')}.png"
    with open(filename, "wb") as f:
        f.write(base64.b64decode(image_base64))

    print(f"Saved image for '{french_word}' to {filename}")


if __name__ == "__main__":
    # 示例：为 "danser" 生成插图
    generate_image_for_word("danser", pos="verb", hint_zh="跳舞")
    # 你可以继续：
    # generate_image_for_word("la voiture", pos="noun (object)", hint_zh="汽车")
    # generate_image_for_word("je", pos="pronoun", hint_zh="我（一个小男孩指向自己）")
