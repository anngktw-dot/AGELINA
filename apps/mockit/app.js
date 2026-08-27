const state = JSON.parse(localStorage.getItem('mockitState') || '{}');

const vacancies = [
  { id: 1, title: 'Junior Backend Developer', team: 'Engineering', candidates: 24 },
  { id: 2, title: 'Product Designer', team: 'Product', candidates: 16 },
  { id: 3, title: 'Sales Development Representative', team: 'Sales', candidates: 31 },
];

function saveState() {
  localStorage.setItem('mockitState', JSON.stringify(state));
}

function showScreen(id) {
  document.querySelectorAll('.screen').forEach((screen) => screen.classList.remove('active'));
  const target = document.getElementById(id);
  if (target) target.classList.add('active');
}

document.addEventListener('click', (event) => {
  const button = event.target.closest('[data-screen]');
  if (button) showScreen(button.dataset.screen);
});

function hydrateOnboarding() {
  document.getElementById('companyName').value = state.companyName || '';
  document.getElementById('companySize').value = state.companySize || '1–20';
  document.getElementById('hiringGoal').value = state.hiringGoal || 'Engineering';
  document.getElementById('hiringVolume').value = state.hiringVolume || '1–5';
}

document.getElementById('saveOnboarding').addEventListener('click', () => {
  state.companyName = document.getElementById('companyName').value.trim();
  state.companySize = document.getElementById('companySize').value;
  state.hiringGoal = document.getElementById('hiringGoal').value;
  state.hiringVolume = document.getElementById('hiringVolume').value;
  saveState();
  document.getElementById('onboardingStatus').textContent = 'Workspace saved for this demo.';
});

function renderVacancies(query = '') {
  const list = document.getElementById('vacancyList');
  const normalized = query.trim().toLowerCase();
  const filtered = vacancies.filter((item) => `${item.title} ${item.team}`.toLowerCase().includes(normalized));
  list.innerHTML = filtered.map((item) => `
    <div class="card vacancy">
      <div>
        <h3>${item.title}</h3>
        <p class="muted">${item.team} · ${item.candidates} candidates</p>
      </div>
      <button data-vacancy="${item.id}">Review candidates</button>
    </div>
  `).join('');
}

document.getElementById('vacancySearch').addEventListener('input', (event) => renderVacancies(event.target.value));

document.getElementById('vacancyList').addEventListener('click', (event) => {
  const button = event.target.closest('[data-vacancy]');
  if (!button) return;
  const vacancy = vacancies.find((item) => item.id === Number(button.dataset.vacancy));
  state.selectedVacancy = vacancy;
  state.candidateName = vacancy.id === 1 ? 'Alex Morgan' : vacancy.id === 2 ? 'Taylor Lee' : 'Jordan Smith';
  state.resumeScore = vacancy.id === 1 ? 86 : vacancy.id === 2 ? 81 : 78;
  saveState();
  renderCandidate();
  showScreen('candidate');
});

function renderCandidate() {
  const vacancy = state.selectedVacancy || vacancies[0];
  document.getElementById('candidateName').textContent = state.candidateName || 'Alex Morgan';
  document.getElementById('candidateRole').textContent = `Applied for ${vacancy.title}`;
  document.getElementById('resumeScore').textContent = state.resumeScore || 82;
}

function calculateDemoScore(text) {
  const clean = text.trim();
  if (!clean) return 0;
  const lengthScore = Math.min(50, Math.round(clean.length / 8));
  const keywords = ['because', 'result', 'team', 'debug', 'api', 'test', 'design', 'learn'];
  const keywordScore = keywords.reduce((score, word) => score + (clean.toLowerCase().includes(word) ? 6 : 0), 0);
  return Math.min(100, 30 + lengthScore + keywordScore);
}

document.getElementById('scoreResponse').addEventListener('click', () => {
  const response = document.getElementById('interviewResponse').value;
  state.interviewResponse = response;
  state.interviewScore = calculateDemoScore(response);
  saveState();
  document.getElementById('interviewScore').textContent = `${state.interviewScore}/100`;
  renderSummary();
});

function renderSummary() {
  const score = state.interviewScore || 0;
  document.getElementById('finalScore').textContent = score;
  const recommendation = score >= 80
    ? 'Strong demo signal — move to the next hiring stage.'
    : score >= 60
      ? 'Mixed demo signal — review notes and continue with targeted follow-up questions.'
      : 'Not enough evidence yet — collect a fuller response before making a decision.';
  document.getElementById('recommendation').textContent = recommendation;
}

let usage = Number(state.usageCount || 12);
function renderUsage() {
  document.getElementById('usageCount').textContent = usage;
}

document.getElementById('addUsage').addEventListener('click', () => {
  usage += 1;
  state.usageCount = usage;
  saveState();
  renderUsage();
});

hydrateOnboarding();
renderVacancies();
renderCandidate();
renderSummary();
renderUsage();
