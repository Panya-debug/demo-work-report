document.addEventListener('DOMContentLoaded', () => {
  // Get current theme from localStorage or default to dark
  const currentTheme = localStorage.getItem('theme') || 'dark';
  document.documentElement.setAttribute('data-theme', currentTheme);
  
  // Create theme toggle button if it doesn't exist
  if (!document.querySelector('.theme-toggle-btn')) {
    const toggleBtn = document.createElement('button');
    toggleBtn.className = 'theme-toggle-btn';
    toggleBtn.setAttribute('aria-label', 'สลับโหมดสว่าง/มืด');
    toggleBtn.innerHTML = currentTheme === 'light' ? '🌙' : '☀️';
    
    toggleBtn.addEventListener('click', () => {
      const activeTheme = document.documentElement.getAttribute('data-theme');
      const newTheme = activeTheme === 'light' ? 'dark' : 'light';
      
      document.documentElement.setAttribute('data-theme', newTheme);
      localStorage.setItem('theme', newTheme);
      toggleBtn.innerHTML = newTheme === 'light' ? '🌙' : '☀️';
    });
    
    document.body.appendChild(toggleBtn);
  }
});
