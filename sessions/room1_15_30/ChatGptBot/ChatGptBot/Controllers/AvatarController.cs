using Microsoft.AspNetCore.Mvc;
using System.Net.Http;
using Azure.Communication.Identity;
using Azure.Communication.NetworkTraversal;
using Azure;
using ChatGptBot.Services;

namespace streaming_avatar_csharp.Controllers;

[ApiController]
[Route("api")]
public class AvatarController : ControllerBase
{
    private readonly IConfiguration _configuration;
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ICompletionService _completionService;

    public AvatarController(IConfiguration configuration, IHttpClientFactory httpClientFactory,ICompletionService completionService)
    {
        _configuration = configuration;
        _httpClientFactory = httpClientFactory;
        _completionService = completionService;
    }

    [HttpPost(template: "getIceServerToken", Name = "getIceServerToken")]
    public async Task<GetIceServerTokenResponse> GetIceServerToken()
    {
        try
        {

            var cnString = GetIceServerConfigData();
            var client = new CommunicationIdentityClient(cnString);


            var identityResponse = await client.CreateUserAsync();
            var identity = identityResponse.Value;
            var relayClient = new CommunicationRelayClient(cnString);


            Response<CommunicationRelayConfiguration> turnTokenResponse =
                await relayClient.GetRelayConfigurationAsync(identity);
            DateTimeOffset turnTokenExpiresOn = turnTokenResponse.Value.ExpiresOn;
            var iceServers = turnTokenResponse.Value.IceServers;
            Console.WriteLine($"Expires On: {turnTokenExpiresOn}");
            foreach (CommunicationIceServer iceServer in iceServers)
            {
                foreach (string url in iceServer.Urls)
                {
                    Console.WriteLine($"TURN Url: {url}");
                }

                return new GetIceServerTokenResponse { Username = iceServer.Username, Credential = iceServer.Credential };
            }

            return new GetIceServerTokenResponse();
        }
        catch (Exception e)
        {
            Console.WriteLine(e);
            return new GetIceServerTokenResponse
            {
                Credential = e.Message,
                Username = "Username"
            };
            //throw;
        }
    }



    [HttpPost(template: "message", Name = "message")]
    public async Task<MessageResponse> Message(List<Message> messages)
    {
        var answer= await _completionService.Ask(new ChatGptBot.Dtos.Completion.Controllers.UserQuestionDto
        {
            ConversationId = Guid.NewGuid(),
            QuestionText = messages.Last().Content
        });   
        var ret = new MessageResponse
        {
            QuestionLanguageCode  = getVoiceCodeFromLanguageCode(answer.QuestionLanguageCode),
            ConversationId =  answer.ConversationId.ToString()    
        };
        ret.Messages.AddRange(messages);
        ret.Messages.Add(new Controllers.Message { Role = "assistant", Content = answer.Answer});
        return ret;
    }
    [HttpPost(template: "detectLanguage", Name = "detectLanguage")]
    public async Task<string> DetectLanguage([FromQuery] string text)
    {
        return "en-US";
        //return "en";
    }


    [HttpPost(template: "getSpeechToken", Name = "getSpeechToken")]
    public async Task<string> GetSpeechToken()
    {

        var configData = GetSpeechConfigData();
        var url = $"https://{configData.Region}.api.cognitive.microsoft.com/sts/v1.0/issueToken";
        var client = _httpClientFactory.CreateClient(url);
        client.DefaultRequestHeaders.Add("Ocp-Apim-Subscription-Key", configData.SubscriptionKey);
        UriBuilder uriBuilder = new UriBuilder(url);

        var result = await client.PostAsync(uriBuilder.Uri.AbsoluteUri, null);
        if (result.IsSuccessStatusCode)
        {
            return await result.Content.ReadAsStringAsync();
        }
        else
        {
            throw new Exception($"could not get speech token url {url} statusCode {result.StatusCode} content {await result.Content.ReadAsStringAsync()}");
        }
    }

    private string GetIceServerConfigData()
    {
        var iceConnectionString = _configuration["iceConnectionString"];
        return iceConnectionString;
    }

    private (string SubscriptionKey, string Region) GetSpeechConfigData()
    {
        var subscriptionKey = _configuration["speechKey"];
        ArgumentException.ThrowIfNullOrEmpty(subscriptionKey);
        var speechRegion = _configuration["speechRegion"];
        ArgumentException.ThrowIfNullOrEmpty(speechRegion);
        return (subscriptionKey, speechRegion);
    }

    private string getVoiceCodeFromLanguageCode(string languageCode)
    {
        if (_LanguageToVoice.TryGetValue(languageCode, out var code))
        {
            return code;
        }
        return _LanguageToVoice["en-US"];
    }

    private Dictionary<string, string> _LanguageToVoice = new Dictionary<string, string>
    {
        {"de", "de-DE"},
        {"en", "en-US"},
        {"es", "es-ES"},
        {"fr", "fr-FR"},
        {"it", "it-IT"},
        {"ja", "ja-JP"},
        {"ko", "ko-KR"},
        {"pt", "pt-BR"},
        {"zh_chs", "zh-CN"},
        {"zh_cht", "zh-CN"},
        {"ar", "ar-AE"}
    };
}

public class Message
{
    public string Role { get; init; } = "";
    public string Content { get; init; } = "";
}

public class GetIceServerTokenResponse
{
    public string Username { get; init; } = "";
    public string Credential { get; init; } = "";
}

public class MessageResponse
{
    public string ConversationId { get; init; } = "";   
    public List<Message> Messages { get; init; } = new();
    public string QuestionLanguageCode { get; set; }
}


