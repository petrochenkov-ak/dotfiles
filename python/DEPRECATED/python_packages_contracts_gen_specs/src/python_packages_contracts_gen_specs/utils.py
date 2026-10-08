def snake_to_pascal(text: str) -> str:
    return "".join(word.capitalize() for word in text.split("_") if word)


def get_model_class_name(table_name: str) -> str:
    if table_name == "base":
        return "BaseModel"
    if table_name.endswith("_queue"):
        base_name = table_name[:-6]
        return f"{snake_to_pascal(base_name)}Task"
    return snake_to_pascal(table_name)
