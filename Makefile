
.PHONY: format
format:
	synx MarkdownTodo.xcodeproj
	swift-format format --in-place --recursive MarkdownTodo

.PHONY:	beta
beta:
	fastlane beta

