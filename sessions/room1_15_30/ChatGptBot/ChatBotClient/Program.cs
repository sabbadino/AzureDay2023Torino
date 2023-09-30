using ChatBotProxy;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace ChatBotClient
{
    internal static class Program
    {
        /// <summary>
        ///  The main entry point for the application.
        /// </summary>
        [STAThread]
        static void Main(string[] args)
        {
            // To customize application configuration such as set high DPI settings or default font,
            // see https://aka.ms/applicationconfiguration.
            ApplicationConfiguration.Initialize();
            var builder = Host.CreateDefaultBuilder(args);
            builder.ConfigureServices((hostContext, services) =>
                {
                    var chatBotApiUrl = hostContext.Configuration["chatBotApiUrl"];
                    ArgumentException.ThrowIfNullOrEmpty(chatBotApiUrl);
                    services.AddSingleton<Form1>();
                   
                    services.AddSingleton<IChatBotClient, ChatBotProxy.ChatBotClient>();

                    // keep as last
                    services.AddHttpClient<IChatBotClient, ChatBotProxy.ChatBotClient>(c =>
                    {
                        c.BaseAddress = new Uri(chatBotApiUrl);
                        c.Timeout = TimeSpan.FromSeconds(200);

                    });
                });
            var host = builder.Build();
            using var scope = host.Services.CreateScope();
            var form = scope.ServiceProvider.GetRequiredService<Form1>();
            Application.Run(form);
        }
    }
}