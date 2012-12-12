Como desenvolver um site utilizando o SiteEngine
================================================

O SiteEngine foi criado com o intuito de ser o ponto de ligação entre o Site
Final e os diversos sistemas da plataforma Alexandria.
A arquitetura do site engine permite que o codebase do site seja distribuído
e gerenciado em cima do git. Isso permite que o desenvolvimento seja realizado 
por equipes diferentes em sincronia.

O objetivo  é facilitar o processo de desenvolvimento interno e de terceiros,
sem depender do SiteTools (edição de templates, áreas, boxes). Dessa maneira,
toda edição dentro do SiteTools podem ser versionadas no repositório git de
acordo com o projeto selecionado. Os desenvolvedores podem clonar o projeto do
repositório (branch) e trabalhar localmente, seja na Abril, em casa e/ou em
empresas terceiras.

Isso permite que alterações realizadas pela equipe de desenvolvimento
diretamente no repositório e alterações feitas pelos webmasters das redações
(via SiteTools) sejam unificadas. O SiteTools tem previlégios em caso de
conflitos de código dos templates. Se ocorrer algum conflito (merge) entre o
código do sitetools e o código produzido fora do SiteTools, o SiteTools vai
sobrescrever o código externo.

Todos os dados, são salvos em arquivos. Não precisa salvar dados em nenhuma
estrutura de banco de dados. Apenas se seu projeto tiver essa necessidade.

Requisitos
----------

* git
* rails 3
* site\_engine

Primeiros passos
----------------

### Iniciando diretório /structure

A seguir, é necessário criar a estrutura do site, que ficará na pasta structure.
Essa estrutura será atualizada pelo SiteTools, e tem a finalidade de armazenar
os templates, assets e as áreas.

A primeira coisa a observar é que o seu site não utilizará o diretório public
como o de constume nos padrões rails. Ao invés dele, usaremos o diretório
assets/public dentro do diretório structure para servir os assets estáticos.

Outra diferença é que o seu site não está utilizando os frameworks ActiveRecord
e ActiveResource. Portanto, se existir a necessidade no projeto e precisar
habilitá-los, deve-se configurar o arquivo `config/application.rb`.

SiteTools, Projetos e Branches
------------------------------

Cada projeto de um site irá corresponder diretamente à uma branch no repositório
structure.
Portanto, ao criar um projeto chamado "Site 2011", o SiteTools irá utilizar a
branch "site2011".
Se a branch não existir, o SiteTools irá criá-la automaticamente usando como
base o último commit da branch "master".

Ao mudar um template, uma área ou asset, o SiteTools grava essa modificação
também no repositório remoto.

Para não lidarmos com conflitos e merges do lado do SiteTools, qualquer
resolução de conflitos é feita usando `git push --force` do lado do SiteTools.
Isso significa que, para cada branch administrada pelo SiteTools, *o SiteTools
predomina os dados em qualquer conflito*.

SiteEngine
----------

Features do SiteEngine:

### Estrutura do site, controller e rotas

A partir do submódulo acoplado ao SiteReference, o SiteEngine é capaz de gerar
as rotas para as áreas criadas.

O arquivo `structure.yml` deve conter todas as áreas e informações relacionadas,
como: outras áreas aninhadas(filhas), template a ser usado pela área e entry
points dos recursos disponíveis dessa área (que se tornarão variáveis de
instância no controller e view).

O SiteEngine é responsável por renderizar todas as áreas. Para sobrescrever uma
área específica no projeto, basta adicioná-la ao arquivo de rotas:

    Rails.application.routes.draw do
      match "minha_area" => "meu_controller#action"
    end

Além disso, existem rotas específicas para controllers que lidam com comentários
e enquetes. Para mais informações rode o comando `rake routes`. Primeiramente, o
Rails se encarrega de carregar as rotas do Engine e somente depois, carregas as
rotas do próprio projeto.

### Public

Para servir arquivos estáticos através do asset server, os arquivos devem ser
colocados na pasta structure/assets/public.

### Novo diretório de templates

Seta o diretorio structure/templates como lookup de views. Portanto, um
`render "/erro"` também procurará pelo arquivo `structure/templates/erro.erb`
(ou outros, dependendo dos template handlers registrados).

Não utilize subdiretórios dentro de `structure/templates`. Apesar do render
funcionar, o SiteTools não está preparado para entender subdiretórios em
templates.

### Helpers

Existem diversos helpers que podem facilitar o desenvolvimento para o webmaster.
Helpers de comentários, enquetes, visualização de imagens e vídeos, busca por
conteúdos, blocos, dentre outras opções. Para mais informações veja os manuais
no [Confluence](https://confluence.abril.com.br/display/engdev/Renders).
