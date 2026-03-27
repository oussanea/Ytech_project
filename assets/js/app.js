// HR Management System - JavaScript
document.addEventListener('DOMContentLoaded', function () {

    const sidebar        = document.getElementById('sidebar');
    const overlay        = document.getElementById('sidebarOverlay');
    const toggleBtn      = document.getElementById('sidebarCollapse');
    const closeBtn       = document.getElementById('sidebarClose');

    function openSidebar() {
        sidebar.classList.add('active');
        overlay.classList.add('active');
        document.body.style.overflow = 'hidden'; // prevent background scroll on mobile
    }

    function closeSidebar() {
        sidebar.classList.remove('active');
        overlay.classList.remove('active');
        document.body.style.overflow = '';
    }

    // Toggle button (hamburger in navbar)
    if (toggleBtn) {
        toggleBtn.addEventListener('click', function () {
            if (sidebar.classList.contains('active')) {
                closeSidebar();
            } else {
                openSidebar();
            }
        });
    }

    // Close button inside sidebar (visible on mobile)
    if (closeBtn) {
        closeBtn.addEventListener('click', closeSidebar);
    }

    // Clicking the overlay closes the sidebar
    if (overlay) {
        overlay.addEventListener('click', closeSidebar);
    }

    // On desktop resize, clean up any leftover mobile state
    window.addEventListener('resize', function () {
        if (window.innerWidth >= 768) {
            closeSidebar();
        }
    });

});
