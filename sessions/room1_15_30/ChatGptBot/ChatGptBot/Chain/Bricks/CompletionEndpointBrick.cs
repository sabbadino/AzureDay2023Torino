using Azure.AI.OpenAI;
using ChatGptBot.Chain.Dto;
using ChatGptBot.Ioc;
using ChatGptBot.Settings;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;
using Microsoft.Extensions.Options;

namespace ChatGptBot.Chain.Bricks;

public class CompletionEndpointBrick : LangChainBrickBase, ILangChainBrick, ISingletonScope
{
    private readonly OpenAIClient _openAiClient;
    private readonly TelemetryClient _telemetryClient;
    private readonly ChatGptSettings _chatGptSettings;

    public CompletionEndpointBrick(OpenAIClient openAiClient, IOptions<ChatGptSettings> openAiSettings, TelemetryClient telemetryClient)
    {
        _openAiClient = openAiClient;
        _telemetryClient = telemetryClient;
        _chatGptSettings = openAiSettings.Value;
    }

    public override async Task<Answer> Ask(Question question)
    {
        using var op = _telemetryClient.StartOperation<DependencyTelemetry>(nameof(CompletionEndpointBrick));
        try
        {
            if (string.IsNullOrEmpty(question.UserQuestion.Text))
            {
                throw new Exception($"{nameof(Question)} is null");
            }

            var chatCompletionsOptions = new ChatCompletionsOptions();
            question.SystemMessages.ForEach(systemMessage =>
            {
                if (!string.IsNullOrEmpty(systemMessage.Text))
                {
                    chatCompletionsOptions.Messages.Add(new
                        ChatMessage(ChatRole.System, systemMessage.Text));
                }
            });

            question.ContextIntroMessages.ForEach(contentIntroMessage => chatCompletionsOptions.Messages.Add(new
                ChatMessage(ChatRole.User, contentIntroMessage.Text)));

            question.ContextMessages.OrderBy(c => c.Proximity).ToList()
                .ForEach(contentMessage => chatCompletionsOptions.Messages.Add(new
                ChatMessage(ChatRole.User, contentMessage.Text)));


            AddChatHistory(chatCompletionsOptions, question.ConversationHistoryMessages);

            chatCompletionsOptions.Messages.Add(new ChatMessage(ChatRole.User, $"{question.UserQuestion.Text}  (answer me only if the question is not out of the scope of the assistant domain, otherwise just say 'I don't know' and apologize for the inconvenience. Do not use your existing knowledge to answer questions that are unrelated to the chatbot's purpose)"));

            chatCompletionsOptions.Temperature = question.QuestionOptions.Temperature;


            var response = await _openAiClient.GetChatCompletionsAsync(
                deploymentOrModelName: question.ModelName,
                chatCompletionsOptions);
            var completion = response.Value.Choices[0].Message;

            return new Answer { AnswerFromChatGpt = completion.Content??""};
        }
        catch (Exception)

        {
            op.Telemetry.Success = false;
            throw;
        }
    }

    private static void AddChatHistory(ChatCompletionsOptions chatCompletionsOptions, List<ConversationHistoryMessage> conversationHistoryMessages)
    {

        foreach (var conversationHistoryMessage in conversationHistoryMessages)
        {
            chatCompletionsOptions.Messages.Add(new ChatMessage
            {
                Role = ChatMessageExtensions.ChatRoleFromString(conversationHistoryMessage.ChatRole),
                Content = conversationHistoryMessage.Text
            });
        }


    }

}

