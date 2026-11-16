// Oportunidades fictícias para demonstrar gerenciamento de itens de configuração.
const oportunidades = [
  { titulo: 'Reforço escolar', area: 'Educação', local: 'Joinville · SC', descricao: 'Apoie estudantes em atividades de leitura e matemática.' },
  { titulo: 'Cuidado animal', area: 'Animais', local: 'Joinville · SC', descricao: 'Colabore em ações de conscientização sobre bem-estar animal.' },
  { titulo: 'Rede de alimentos', area: 'Assistência social', local: 'Joinville · SC', descricao: 'Participe da organização de doações de alimentos.' },
  { titulo: 'Inclusão digital', area: 'Tecnologia', local: 'Joinville · SC', descricao: 'Ajude pessoas a desenvolver habilidades digitais básicas.' },
  { titulo: 'Plantio comunitário', area: 'Meio ambiente', local: 'Joinville · SC', descricao: 'Apoie atividades de cultivo e cuidado com espaços verdes.' },
  { titulo: 'Oficinas criativas', area: 'Cultura', local: 'Joinville · SC', descricao: 'Contribua com oficinas de arte, música e expressão.' },
];

const busca = document.querySelector('#busca');
const lista = document.querySelector('#lista');
const contador = document.querySelector('#contador');

function normalizar(texto) {
  return texto.normalize('NFD').replace(/[\u0300-\u036f]/g, '').toLowerCase();
}

function criarCartao(item) {
  const article = document.createElement('article');
  article.className = 'card';

  const area = document.createElement('div');
  area.className = 'category';
  area.textContent = item.area;

  const titulo = document.createElement('h3');
  titulo.textContent = item.titulo;

  const descricao = document.createElement('p');
  descricao.textContent = item.descricao;

  const local = document.createElement('p');
  local.className = 'local';
  local.textContent = `📍 ${item.local}`;

  article.append(area, titulo, descricao, local);
  return article;
}

function atualizarLista() {
  const termo = normalizar(busca.value.trim());
  const encontrados = oportunidades.filter((item) =>
    normalizar(`${item.titulo} ${item.area} ${item.local} ${item.descricao}`).includes(termo)
  );

  lista.replaceChildren();
  contador.textContent = `${encontrados.length} oportunidade(s) encontrada(s)`;

  if (!encontrados.length) {
    const vazio = document.createElement('p');
    vazio.className = 'no-results';
    vazio.textContent = 'Nenhuma oportunidade encontrada para esse filtro.';
    lista.append(vazio);
    return;
  }
  encontrados.forEach((item) => lista.append(criarCartao(item)));
}

busca.addEventListener('input', atualizarLista);
atualizarLista();
