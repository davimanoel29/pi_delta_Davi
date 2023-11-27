import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class SupportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Suporte'),
        backgroundColor: Color(0xFFA52502),
      ),
      body: SingleChildScrollView(
        child: Html(
          data: '''
            <html>
              <body>
                <div style="text-align: center; padding: 20px;">
                  <h1>Bem-vindo à página de suporte de Delta Produtos Esportivos.</h1>
                  <div style="text-align: left; margin-top: 20px; margin-left: 20px;">
                    <h2>Informações de Contato:</h2>
                    <p>Telefone: (11) 1234-5678</p>
                    <p>E-mail: suporte@delta.com</p>
                    <p>Para mais informações, utilize em nossa página web nosso assistente virtual Delta.</p>
                  </div>
                </div>
                <script>
                  window.watsonAssistantChatOptions = {
                    integrationID: "47e110dd-8723-4557-9294-f0ceadcb8aa4",
                    region: "us-south",
                    serviceInstanceID: "90c6dcc4-d1e3-44bb-818d-3bd4dc8c9ae0",
                    onLoad: async (instance) => { await instance.render(); }
                  };
                  setTimeout(function(){
                    const t=document.createElement('script');
                    t.src="https://web-chat.global.assistant.watson.appdomain.cloud/versions/" + (window.watsonAssistantChatOptions.clientVersion || 'latest') + "/WatsonAssistantChatEntry.js";
                    document.head.appendChild(t);
                  });
                </script>
              </body>
            </html>
          ''',
        ),
      ),
    );
  }
}
