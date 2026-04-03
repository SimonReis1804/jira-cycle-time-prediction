def map_issue_type(issue_type):
    issue_type = issue_type.lower()
    if issue_type in ["bug", "defect", "problem", "public security vulnerability"]:
        return "BUG"
    elif issue_type in ["new feature", "story", "suggestion"]:
        return "FEATURE"
    elif issue_type in ["improvement", "refactoring", "technical debt", "pruning", "feedback"]:
        return "IMPROVEMENT"
    elif issue_type in ["task", "technical task", "development task", "test task"]:
        return "TASK"
    elif issue_type in ["support", "support request", "it help", "questions", "ask a question"]:
        return "SUPPORT"
    elif issue_type in ["documentation"]:
        return "DOC"
    elif issue_type in ["epic", "initiative", "forge initiative"]:
        return "EPIC"
    elif issue_type in ["sub-task", "subtask", "sub-task"]:
        return "SUBTASK"
    else:
        return "OTHER"
