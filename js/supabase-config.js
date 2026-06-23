const SB_URL = 'https://peguurmaztaxvgdhclua.supabase.co';
const SB_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBlZ3V1cm1henRheHZnZGhjbHVhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODIxOTI3NDgsImV4cCI6MjA5Nzc2ODc0OH0.Hu5beV4DZWM8-81fR1d-AK5cKn7Wt00t6QG3SG3qRCk';

// Capture SDK and initialize client into the global window.supabase
if (window.supabase && typeof window.supabase.createClient === 'function') {
    const sdk = window.supabase;
    window.supabase = sdk.createClient(SB_URL, SB_KEY);
}

// Expose a safe global variable 'supabase' pointing to the client
var supabase = window.supabase;

// Inject the connection status dot styling and element
(function injectStatusDot() {
    const style = document.createElement('style');
    style.textContent = `
      .db-status-badge {
        position: absolute;
        bottom: -2px;
        right: -2px;
        width: 10px;
        height: 10px;
        border-radius: 50%;
        border: 2px solid #0f172a;
        background: #ef4444;
        box-shadow: 0 0 6px #ef4444;
        transition: background 0.3s, box-shadow 0.3s;
        z-index: 10;
        cursor: help;
      }
    `;
    document.head.appendChild(style);

    function setupDot() {
        const logoIcon = document.querySelector('.logo-icon, .sidebar-logo-icon');
        if (logoIcon) {
            // Ensure container has relative positioning
            logoIcon.style.position = 'relative';
            if (!logoIcon.querySelector('.db-status-badge')) {
                const dot = document.createElement('span');
                dot.className = 'db-status-badge';
                dot.title = 'Supabase Disconnected';
                logoIcon.appendChild(dot);
            }
        } else {
            // Retry in case DOM isn't fully loaded
            setTimeout(setupDot, 100);
        }
    }

    window.setSupabaseStatus = function(connected, errorMsg = '') {
        const dot = document.querySelector('.db-status-badge');
        if (dot) {
            if (connected) {
                dot.style.background = '#10b981'; // Green
                dot.style.boxShadow = '0 0 6px #10b981';
                dot.title = 'Supabase Connected';
            } else {
                dot.style.background = '#ef4444'; // Red
                dot.style.boxShadow = '0 0 6px #ef4444';
                dot.title = 'Supabase Disconnected' + (errorMsg ? ' (' + errorMsg + ')' : '');
            }
        }
    };

    // Run setup
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', setupDot);
    } else {
        setupDot();
    }

    // Auto-test connection
    if (supabase) {
        supabase.from('teams').select('id').limit(1)
            .then(({ error, data }) => {
                if (error) {
                    console.error('Supabase connection test failed:', error);
                    window.setSupabaseStatus(false, error.message || JSON.stringify(error));
                } else {
                    window.setSupabaseStatus(true);
                }
            })
            .catch((err) => {
                console.error('Supabase connection test exception:', err);
                window.setSupabaseStatus(false, err.message || err);
            });
    } else {
        window.setSupabaseStatus(false, 'SDK not loaded');
    }
})();
