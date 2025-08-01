let folders = [];

function initClient() {
  gapi.client.init({
    clientId: CLIENT_ID,
    scope: SCOPES
  });
}

function handleAuthClick() {
  gapi.load('client:auth2', () => {
    gapi.auth2.init({ client_id: CLIENT_ID }).then(() => {
      gapi.auth2.getAuthInstance().signIn().then(() => {
        alert("Autenticado con Google Drive");
      });
    });
  });
}

function crearCarpeta() {
  const nombre = document.getElementById('folderName').value;
  if (!nombre) return alert('Escribe un nombre para la clase');

  const id = Date.now();
  folders.push({ id, nombre, contenido: '' });

  mostrarCarpetas();
  document.getElementById('folderName').value = '';
}

function mostrarCarpetas() {
  const contenedor = document.getElementById('folders');
  contenedor.innerHTML = '';
  folders.forEach(folder => {
    const div = document.createElement('div');
    div.className = 'folder';
    div.innerHTML = `
      <h3>${folder.nombre}</h3>
      <textarea placeholder="Escribe aquí..." oninput="guardarTexto(${folder.id}, this.value)">${folder.contenido}</textarea>
    `;
    contenedor.appendChild(div);
  });
}

function guardarTexto(id, texto) {
  const carpeta = folders.find(f => f.id === id);
  if (carpeta) {
    carpeta.contenido = texto;

    // Autoguardado en Google Drive
    guardarEnDrive(carpeta.nombre + ".txt", texto);
  }
}

function guardarAPA() {
  const link = document.getElementById('paperLink').value;
  const title = document.getElementById('paperTitle').value;
  const author = document.getElementById('paperAuthor').value;
  const year = document.getElementById('paperYear').value;

  if (!link || !title || !author || !year) {
    alert("Completa todos los campos");
    return;
  }

  const apa = `${author} (${year}). ${title}. Recuperado de ${link}`;

  const li = document.createElement('li');
  li.textContent = apa;
  document.getElementById('apaList').appendChild(li);

  document.getElementById('paperLink').value = '';
  document.getElementById('paperTitle').value = '';
  document.getElementById('paperAuthor').value = '';
  document.getElementById('paperYear').value = '';
}

function guardarEnDrive(nombreArchivo, contenido) {
  const file = new Blob([contenido], { type: 'text/plain' });
  const metadata = {
    name: nombreArchivo,
    mimeType: 'text/plain'
  };

  const accessToken = gapi.auth.getToken().access_token;
  const form = new FormData();
  form.append('metadata', new Blob([JSON.stringify(metadata)], { type: 'application/json' }));
  form.append('file', file);

  fetch('https://www.googleapis.com/upload/drive/v3/files?uploadType=multipart&fields=id', {
    method: 'POST',
    headers: new Headers({ 'Authorization': 'Bearer ' + accessToken }),
    body: form
  })
  .then(res => res.json())
  .then(val => {
    console.log('Guardado en Drive con ID: ' + val.id);
  });
}
