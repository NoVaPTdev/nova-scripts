const container = document.getElementById('notify-container');
const icons = { success: '✓', error: '✕', info: 'i', warning: '!' };

function createToast(message, type, duration) {
    const toast = document.createElement('div');
    toast.className = 'toast ' + (type || 'info');

    toast.innerHTML =
        '<div class="toast-icon">' + (icons[type] || icons.info) + '</div>' +
        '<div class="toast-message">' + message + '</div>' +
        '<div class="toast-progress" style="animation-duration: ' + duration + 'ms"></div>';

    container.appendChild(toast);

    setTimeout(function () {
        toast.classList.add('removing');
        setTimeout(function () { toast.remove(); }, 300);
    }, duration);

    if (container.children.length > 5) {
        container.firstChild.remove();
    }
}

window.addEventListener('message', function (e) {
    if (e.data.action === 'notify') {
        createToast(e.data.message, e.data.type, e.data.duration || 5000);
    }
});
