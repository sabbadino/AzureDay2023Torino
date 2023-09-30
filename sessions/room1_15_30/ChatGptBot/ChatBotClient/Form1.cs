using ChatBotProxy;
using Microsoft.Extensions.Configuration;
using Microsoft.Win32;
using System.Configuration;
using System.Drawing;

namespace ChatBotClient
{
    public partial class Form1 : Form
    {
        private readonly IChatBotClient _chatBotClient;
        private readonly IConfiguration _configuration;

        private Guid _conversationId = Guid.NewGuid();
        public Form1(IChatBotClient chatBotClient,IConfiguration configuration)
        {
            _chatBotClient = chatBotClient;
            _configuration = configuration;
            InitializeComponent();
        }
        private async Task InitializeAsync()
        {
            await myWebView.EnsureCoreWebView2Async(null);
        }

        private int _counter;
        private void AddConversationITem(Color bgColor, Color foreColor, ContentAlignment contentAlignment, string text)
        {
            var t = new Label
            {
                TextAlign = contentAlignment,
                AutoSize = true,
                Dock = DockStyle.Fill,
                Font = new Font("Segoe UI", 14),
                BorderStyle = BorderStyle.FixedSingle,
                Text = text,
                Padding = new Padding { All = 15 },
                BackColor = bgColor,
                ForeColor = foreColor
            };
            Conversation.Controls.Add(t, 0, _counter++);
            t.Focus();

        }

        private async void Form1_Load(object sender, EventArgs e)
        {
            await InitializeAsync();
            var webViewUrl = _configuration["WebViewUrl"];
            ArgumentException.ThrowIfNullOrEmpty(webViewUrl);
            myWebView.Source = new Uri(webViewUrl);
            AddConversationITem(Color.White, Color.Black, ContentAlignment.BottomLeft, "Hi, I am your myMSC ChatBot assistant. How can I help you ?");

        }



        private async Task SendQuestion(string questionText)
        {
            try
            {
                if (!string.IsNullOrEmpty(questionText))
                {
                    AddConversationITem(Color.DarkCyan, Color.White, ContentAlignment.MiddleRight, questionText);
                    SearchStarted();
                    var ret = await _chatBotClient.AskAsync(new UserQuestionDto
                    {
                        QuestionText = questionText,
                        ConversationId = _conversationId
                    });
                    var answer = ret.Answer;
                    AddConversationITem(Color.White, Color.Black, ContentAlignment.MiddleLeft, answer);
                }
            }
            catch (Exception ex)
            {
                AddConversationITem(Color.White, Color.Black, ContentAlignment.MiddleLeft, "sorry there was an error processing the request. Try again later");
                MessageBox.Show(ex.ToString());
            }
            finally
            {
                SearchEnded();
            }
        }

        private void SearchEnded()
        {
            textBox1.ReadOnly = false;
            button1.Enabled = true;
            button2.Enabled = true;
            progressBar1.Style = ProgressBarStyle.Blocks;
        }
        private void SearchStarted()
        {
            textBox1.Text = "";
            textBox1.ReadOnly = true;
            button1.Enabled = false;
            button2.Enabled = false;
            progressBar1.Style = ProgressBarStyle.Marquee;
        }
        private async void button1_Click_1(object sender, EventArgs e)
        {
            await SendQuestion(textBox1.Text);
        }

        private void button2_Click(object sender, EventArgs e)
        {
            _conversationId = Guid.NewGuid();
            textBox1.Text = "";
            Conversation.Controls.Clear();
            AddConversationITem(Color.White, Color.Black, ContentAlignment.BottomLeft, "Hi, I am your myMsc ChatBot assistant. How can I help you ?");

        }
    }
}