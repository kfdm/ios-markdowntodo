
.PHONY: format
format:
	swift-format format --in-place --recursive MarkdownTodo TodayWidget

.PHONY:	beta
beta:
	fastlane beta

