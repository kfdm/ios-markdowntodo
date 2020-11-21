
.PHONY: format
format:
	swift-format format --in-place --recursive MarkdownTodo

.PHONY:	beta
beta:
	fastlane beta

