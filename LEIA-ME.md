# Minha Agenda – como colocar para funcionar

O app é feito de `index.html` (estrutura), `css/style.css` (visual) e `js/` (configuração e lógica). Ele guarda os dados no **Supabase** (gratuito para começar). Cada profissional cria a própria conta e só vê os próprios pacientes.

## 1. Criar o banco
1. Crie um projeto em https://supabase.com.
2. Abra **SQL Editor**, cole o conteúdo de `supabase.sql` e clique em **Run**.
   O arquivo já inclui as permissões (`GRANT`) que o Supabase passa a exigir para tabelas novas em `public`. Se aparecer o erro "permission denied for table", é porque faltou rodar essa parte.
3. Confira em **Project Settings → API** (Data API) se o schema `public` está exposto.

## 2. Ligar o app ao banco
1. No Supabase, vá em **Project Settings → API**.
2. Copie a **Project URL** e a chave **anon / publishable**.
3. Abra o arquivo `js/config.js` e preencha:
   ```js
   var SUPABASE_URL = "https://SEU-PROJETO.supabase.co";
   var SUPABASE_KEY = "sua-chave-publica";
   ```
   Use apenas a chave pública. **Nunca** coloque a chave `service_role` no arquivo.

## Testar no VS Code (Live Server)
1. Descompacte o `minha-agenda.zip`. As pastas `css` e `js` devem ficar **ao lado** do `index.html`.
2. No VS Code: **File → Open Folder** e escolha a pasta `minha-agenda`.
3. Instale a extensão **Live Server** (Ritwick Dey).
4. Clique com o botão direito no `index.html` → **Open with Live Server**. Abra no navegador (Chrome/Edge), não na visualização embutida do VS Code.
5. Se aparecer "Configuração pendente", preencha `js/config.js`. Se aparecer "Carregando…" sem sair, as pastas `css`/`js` não estão ao lado do `index.html`. Se aparecer "Erro no script", a mensagem diz o que houve.

**Tela preta?** Costuma ser o `index.html` aberto sem as pastas `css` e `js` (baixados um por um, sem as pastas) ou aberto na visualização embutida do VS Code. Use o zip e o Live Server.

## 3. Publicar
Suba a pasta inteira (`index.html`, `css/` e `js/`) em qualquer hospedagem de site estático (Netlify, Vercel, GitHub Pages, Cloudflare Pages). O endereço precisa ser **https**.

## 4. Autenticação
Em **Authentication → URL Configuration**, ponha o endereço do seu site em **Site URL** e em **Redirect URLs** (usado pelo link de "Esqueci minha senha").
Para a pessoa entrar **na hora** depois de criar a conta, desligue **Authentication → Sign In / Providers → Email → Confirm email**. Com isso o app faz o login automático e ninguém precisa abrir o e-mail.
O nome informado no cadastro ("Como você gostaria de ser chamado?") fica salvo na tabela `profiles`, ligado à conta.

## 5. Usar no celular
- **iPhone (Safari):** Compartilhar → Adicionar à Tela de Início.
- **Android (Chrome):** menu ⋮ → Instalar app / Adicionar à tela inicial.

## Sobre os lembretes
Os avisos funcionam **com o app aberto** (ou aberto em segundo plano): tela com aviso, e notificação do navegador se você tocar no sino 🔔 e permitir. Com o app totalmente fechado, o navegador não consegue disparar avisos sozinho. Para isso seria preciso um serviço de push ou um app nativo.
