const qrcode = require('qrcode-terminal');
const { Client } = require('whatsapp-web.js');
const request = require('request');
const chromePaths = require('chrome-paths');
const readline = require('readline-sync');
const fs = require('fs');
const axios = require('axios');
const moment = require('moment-timezone');
const cheerio = require('cheerio');
const path = require('path'); // Import module 'path' untuk bekerja dengan path direktori
const { MessageMedia } = require('whatsapp-web.js');
let botActive = false;

function dateShow() {
    return `[${moment().format('DD-MM-YY HH:mm:ss')}]`;
}

let client;

try {
  client = new Client({
 
    puppeteer: {
      executablePath: chromePaths.chrome,
        headless: true,
        args: [ '--no-sandbox', '--disable-gpu', ],
    },
    webVersionCache: { type: 'remote', remotePath: 'https://raw.githubusercontent.com/wppconnect-team/wa-version/main/html/2.2412.54.html', }
});

} catch (e) {
  client = new Client({
 
    puppeteer: {
      executablePath: chromePaths.chrome,
        headless: true,
        args: [ '--no-sandbox', '--disable-gpu', ],
    },
    webVersionCache: { type: 'remote', remotePath: 'https://raw.githubusercontent.com/wppconnect-team/wa-version/main/html/2.2412.54.html', }
});
}

const params = {
    'limit': '20',
};

client.on('qr', (qr) => {
  // Generate and scan this QR code with your phone
  qrcode.generate(qr, { small: true });
});

client.on('authenticated', () => {
  console.log('Client is authenticated!');
});

let texts = [];
let err = '';
function ambilKataKunci(string) {
  const polaRule1 = /c=([a-zA-Z0-9]{9})/;
  const polaRule2 = /([a-zA-Z0-9]{9})&/;
  const polaRule3 = /c=([a-zA-Z0-9]{9})&r=([a-zA-Z0-9]+)/;
  const polaRule4 = /([a-zA-Z0-9]+)&r=([a-zA-Z0-9]+)/;

  const hasilRule1 = string.match(polaRule1);
  const hasilRule2 = string.match(polaRule2);
  const hasilRule3 = string.match(polaRule3);
  const hasilRule4 = string.match(polaRule4);

  if (hasilRule1) {
      return [hasilRule1[1], "rule 1"];
  } else if (hasilRule2) {
      return [hasilRule2[1], "rule 2"];
  } else if (hasilRule3) {
      return [hasilRule3[0], "rule 3"];
  } else if (hasilRule4) {
      return [hasilRule4[0], "rule 4"];
  } else {
      return [null, "tidak ada aturan yang cocok"];
  }
}

function perbaruiURL(kataKunci, aturan) {
  if (aturan === "rule 1" || aturan === "rule 3") {
      return `https://link.dana.id/kaget?c=${kataKunci}`;
  } else if (aturan === "rule 2" || aturan === "rule 4") {
      return `https://link.dana.id/kaget?c=${kataKunci}`;
  }
}

// Contoh penggunaan
function trimLastWord(str) {
  // Memisahkan string berdasarkan spasi
  let words = str.split(' ');
  
  // Mendapatkan kata terakhir
  let lastWord = words.pop();
  
  // Trim kata terakhir
  lastWord = lastWord.trim();
  
  // Menggabungkan kembali string dengan kata terakhir yang sudah di-trim
  words.push(lastWord);
  
  // Menggabungkan kembali semua kata menjadi satu string
  return words.join(' ');
}
 
async function pollStationheadAndSendMessage(client) {
  let data = fs.readFileSync('data.txt', 'utf8');
  data = trimLastWord(data)
  const headers = {
    'accept': '*/*',
    'accept-language': 'en-US,en;q=0.9',
    'app-platform': 'web',
    'app-version': '1.0.0',
    'authorization': `${data}`,
    'content-type': 'application/json',
    'origin': 'https://app.stationhead.com',
    'referer': 'https://app.stationhead.com/',
    'sec-ch-ua': '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
    'sth-device-uid': 'e9ada383-4c26-4039-af2b-945bc17c4f30',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
};
  try {
    const response = await axios.get('https://production1.stationhead.com/station/2599244/chatHistory', { params, headers });

    const data = response.data;
 
    for (const item of data['chats']['items']) {
      const text = item['text'];
      if (!texts.includes(text)) {
        console.log(`${dateShow()} ${text}`);
        if (text.includes('https://link.dana.id/kaget?')) {
          // Mengirimkan pesan ke grup WhatsApp
          client.sendMessage('120363284534789091@g.us', `[ From SH - Server 2] [ Pengirim Daget: ${item['account']['handle']} ] ${text}`,{mentions:[  '6285264393593@c.us',  '6282268527710@c.us',  '6282178814057@c.us','6281364542017@c.us',  '6282172017725@c.us',  '62895618367448@c.us',  '6282174448003@c.us',  '6281378738608@c.us',  '6281365955980@c.us']})
          client.sendMessage('6285264393593@c.us', `[ From SH - Server 2] [ Pengirim Daget: ${item['account']['handle']} ] ${text}`)
          checkListeners();

         }
        else{
            const [kataKunci, aturan] = ambilKataKunci(text);
            if (kataKunci) {
            
                const urlBaru = perbaruiURL(kataKunci, aturan);
                client.sendMessage('120363284534789091@g.us', `[ From SH - Server 2] [ Pengirim Daget: ${item['account']['handle']} ] ${urlBaru}`,{mentions:[  '6285264393593@c.us',  '6282268527710@c.us',  '6282178814057@c.us','6281364542017@c.us',  '6282172017725@c.us',  '62895618367448@c.us',  '6282174448003@c.us',  '6281378738608@c.us',  '6281365955980@c.us']})
                client.sendMessage('6285264393593@c.us', `[ From SH - Server 2] [ Pengirim Daget: ${item['account']['handle']} ] ${urlBaru}`)
                checkListeners();

             }
        }
      
        texts.push(text);
      }
    }
  } catch (error) {
    if (error.response) {
      if (error.response.status === 429) {
        console.log('Rate limited. Retrying after 5 seconds...');
        await new Promise(resolve => setTimeout(resolve, 5000));
        // Retry the request here
        // const response = await axios.get('your-api-endpoint');
      } else if (error.response.status === 401) {
        console.log('Unauthorized. Logging in...');
        const url = "https://production1.stationhead.com/login";
        const email = "dedulz18@gmail.com";  // Replace with your email
        const password = "realmadrid1";  // Replace with your password
    
        const payload = {
            "username": email,
            "password": password,
            "resalt": true,
            "clear_broadcast_data": true
        };
    
        const headers = {
            'accept': '*/*',
            'accept-language': 'en-US,en;q=0.9',
            'app-platform': 'web',
            'app-version': '1.0.0',
            'content-type': 'application/json',
            'origin': 'https://app.stationhead.com',
            'referer': 'https://app.stationhead.com/',
            'sec-ch-ua': '"Chromium";v="124", "Google Chrome";v="124", "Not-A.Brand";v="99"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"Windows"',
            'sec-fetch-dest': 'empty',
            'sec-fetch-mode': 'cors',
            'sec-fetch-site': 'same-site',
        };
    
        try {
            const response = await axios.post(url, payload, { headers: headers });

            const token = response.headers['authorization'];
            console.log('Login successful');
            fs.writeFileSync('data.txt', token, 'utf8');
        } catch (loginError) {
            console.log("Failed to login:", loginError);
        }
      } else {
        console.log('Error response:', error.response.data);
      }
    } else if (error.request) {
      console.log('No response received:', error.request);
    } else {
      console.log('Error:', error.message);
      
    }
  }
}

async function searchStationheadListener(handle) {
  const data = fs.readFileSync('data.txt', 'utf8');

  const headers = {
    'accept': '*/*',
    'accept-language': 'en-US,en;q=0.9',
    'app-platform': 'web',
    'app-version': '1.0.0',
    'authorization': `${data}`,
    'content-type': 'application/json',
    'origin': 'https://app.stationhead.com',
    'referer': 'https://app.stationhead.com/',
    'sec-ch-ua': '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'sec-fetch-dest': 'empty',
    'sec-fetch-mode': 'cors',
    'sec-fetch-site': 'same-site',
    'sth-device-uid': 'e9ada383-4c26-4039-af2b-945bc17c4f30',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
  };
  try {
    const response = await axios.get(`https://production1.stationhead.com/station/2599244/listener/search?handle=${handle}`, { headers });
    const listenerData = response.data.accounts;

    if (listenerData && listenerData.length > 0) {
      return listenerData;
    } else {
      return null;
    }
  } catch (error) {
    console.error(`Failed to search listener: ${error}`);
    return null;
  }
}

client.on('ready', () => {
  console.log('Klien siap!');
 
 });

async function searchListenersForHandles(handles) {
  const foundListeners = [];
  const notFoundHandles = [];

  for (const handle of handles) {
    const username = await searchStationheadListener(handle);
    if (username) {
      foundListeners.push({ handle, username });
    } else {
      notFoundHandles.push(handle);
    }
  }

  return { foundListeners, notFoundHandles };
}

// Fungsi untuk mengirim pesan berisi daftar listener yang ditemukan dan yang tidak ditemukan
async function sendSearchResultsToWhatsApp(foundListeners, notFoundHandles) {
  let message = "Listener yang ditemukan:\n";
  for (const listener of foundListeners) {
    message += `${listener.handle})\n`;
  }

  if (notFoundHandles.length > 0) {
    message += "\nHandle yang tidak ditemukan:\n";
    for (const handle of notFoundHandles) {
      message += `${handle}\n`;
    }
  }

  await client.sendMessage('120363284534789091@g.us', message);
}

// Fungsi untuk menjalankan pencarian setiap 10 menit
async function checkListeners() {
  const handles = ["mawarrni", "arracille", "anggiel", "nuvaja", "gresia18", "evenata", "tinazai", "silquinn", "mutewak", "shaarea"];

  const { foundListeners, notFoundHandles } = await searchListenersForHandles(handles);
  await sendSearchResultsToWhatsApp(foundListeners, notFoundHandles);
}

client.on('message_create', async msg => {

    try {
        const messageContent = msg.body.toLowerCase(); // Ubah ke huruf kecil agar case insensitive
        const sender = msg.from;
        const allowedSenders = ['6281364542017@c.us', '6285264393593@c.us'];
        // Periksa apakah pengirim pesan adalah salah satu dari nomor yang diizinka
        const timestamp = new Date().toLocaleString(); // Mendapatkan waktu lokal saat ini
    
        if (messageContent === '/start2') {
            if (!allowedSenders.includes(sender)) {
                await client.sendMessage(sender, '[Server 2]Anda tidak diizinkan untuk menggunakan keyword ini, mohon hubungi admin');
                return // Hentikan eksekusi jika pengirim tidak diizinkan
            }

            else{
        
          // Kirim pesan konfirmasi
                await client.sendMessage('120363284534789091@g.us', '[Server 2] Bot sudah aktif, check status bot, ketik /status2!');
          // Mulai polling
                intervalId = setInterval(() => pollStationheadAndSendMessage(client), 0.1);
                botActive = true;
            }
        } else if (messageContent === '/stop2') {
            if (!allowedSenders.includes(sender)) {
                await client.sendMessage(sender, '[Server 2] Anda tidak diizinkan untuk menggunakan keyword ini, mohon hubungi admin');
                return // Hentikan eksekusi jika pengirim tidak diizinkan
            }

            else{
          // Kirim pesan konfirmasi
          await client.sendMessage('120363284534789091@g.us', '[Server 2] Bot dihentikan! Untuk mengaktifkannya, ketik /start');
          // Menghentikan polling
          clearInterval(intervalId);
          botActive = false;
            }
        } else if (messageContent === '/status2') {
          const data = fs.readFileSync('data.txt', 'utf8');
    
          const headers = {
            'accept': '*/*',
            'accept-language': 'en-US,en;q=0.9',
            'app-platform': 'web',
            'app-version': '1.0.0',
            'authorization': `${data}`,
            'content-type': 'application/json',
            'origin': 'https://app.stationhead.com',
            'referer': 'https://app.stationhead.com/',
            'sec-ch-ua': '"Google Chrome";v="123", "Not:A-Brand";v="8", "Chromium";v="123"',
            'sec-ch-ua-mobile': '?0',
            'sec-ch-ua-platform': '"Windows"',
            'sec-fetch-dest': 'empty',
            'sec-fetch-mode': 'cors',
            'sec-fetch-site': 'same-site',
            'sth-device-uid': 'e9ada383-4c26-4039-af2b-945bc17c4f30',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          };
    
          const botStatus = botActive ? 'Bot sudah aktif' : 'Bot belum aktif';
          const response = await axios.get('https://production1.stationhead.com/station/2599244/chatHistory', { headers });
          const statusCode = response.status;
          await client.sendMessage('120363284534789091@g.us', `[Server 2] Status bot: ${botStatus}\nStatus Koneksi Bot: ${statusCode === 200 ? 'BAGUS' : 'ERROR'}`);
        } else if (messageContent.startsWith('/search2')) {
          const handle = messageContent.split(' ')[1];
          if (handle) {
            const listenerData = await searchStationheadListener(handle);
            if (listenerData) {
              await client.sendMessage('120363284534789091@g.us', `[Server 2] Data untuk handle ${handle} ditemukan di listener!`);
            } else {
              await client.sendMessage('120363284534789091@g.us', `[Server 2] Tidak ditemukan data untuk handle ${handle}`);
            }
          } else {
            await client.sendMessage('120363284534789091@g.us', '[Server 2] Mohon masukkan handle yang valid!');
          }
        }
      } catch (error) {
        console.log('Error saat menangani pesan:', error);
      }
    });
     
    client.initialize();
