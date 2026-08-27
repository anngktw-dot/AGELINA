const API = 'http://127.0.0.1:8000';
const CHILD_ID = 1;

function formatMinutes(minutes) {
  const hours = Math.floor(minutes / 60);
  const rest = minutes % 60;
  return hours ? `${hours}h ${rest}m` : `${rest}m`;
}

async function loadParentDashboard() {
  const response = await fetch(`${API}/children/${CHILD_ID}`);
  if (!response.ok) throw new Error('Could not load family data');
  const child = await response.json();

  document.getElementById('name').textContent = child.name;
  document.getElementById('status').textContent = child.status;
  document.getElementById('location').textContent = child.location_label;
  document.getElementById('battery').textContent = `${child.battery_percent}%`;
  document.getElementById('screenTime').textContent = formatMinutes(child.screen_time_minutes);
  document.getElementById('lastCheckIn').textContent = new Date(child.last_check_in).toLocaleString();
  document.getElementById('apps').innerHTML = child.top_apps
    .map((app) => `<span class="chip">${app}</span>`)
    .join('');
}

async function sendCheckIn() {
  const status = document.getElementById('statusInput').value.trim();
  const locationLabel = document.getElementById('locationInput').value.trim() || 'Not shared';
  const batteryPercent = Number(document.getElementById('batteryInput').value);
  const result = document.getElementById('result');

  const response = await fetch(`${API}/children/${CHILD_ID}/check-in`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      status,
      location_label: locationLabel,
      battery_percent: batteryPercent,
    }),
  });

  if (!response.ok) {
    result.textContent = 'Could not send the check-in.';
    return;
  }

  result.textContent = 'Check-in sent successfully.';
}

const page = document.body.dataset.page;

if (page === 'parent') {
  loadParentDashboard().catch((error) => {
    document.getElementById('status').textContent = error.message;
  });
  document.getElementById('refresh').addEventListener('click', () => {
    loadParentDashboard().catch(console.error);
  });
}

if (page === 'child') {
  const battery = document.getElementById('batteryInput');
  const batteryValue = document.getElementById('batteryValue');
  battery.addEventListener('input', () => {
    batteryValue.textContent = `${battery.value}%`;
  });
  document.getElementById('sendCheckIn').addEventListener('click', () => {
    sendCheckIn().catch((error) => {
      document.getElementById('result').textContent = error.message;
    });
  });
}
