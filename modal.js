document.addEventListener('DOMContentLoaded', () => {
    const modalHTML = `
    <div id="acmMembershipModal" style="display: none; position: fixed; z-index: 10000; left: 0; top: 0; width: 100%; height: 100%; align-items: center; justify-content: center; background-color: rgba(0,0,0,0.5); backdrop-filter: blur(3px);">
        <div style="background-color: var(--white); padding: 32px; border-radius: var(--radius); max-width: 400px; width: 90%; text-align: center; position: relative; box-shadow: var(--shadow-lg);">
            <button id="closeAcmModalBtn" style="position: absolute; top: 12px; right: 16px; background: none; border: none; font-size: 24px; cursor: pointer; color: var(--gray-600);">&times;</button>
            <h2 style="font-size: 1.5rem; margin-bottom: 24px; color: var(--navy);">Select Membership</h2>
            <div style="display: flex; flex-direction: column; gap: 16px;">
                <a href="https://services.acm.org/public/qj/quickjoin/qj_control.cfm?promo=PWEBTOP&form_type=Student" class="btn btn--primary btn--lg" target="_blank" rel="noopener" style="width: 100%; justify-content: center; text-decoration: none;">Student Membership</a>
                <a href="https://services.acm.org/public/qj/proflevel/proflevel_control.cfm?level=3&country=India&form_type=Professional&promo=LEVEL&pay=DD" class="btn btn--primary btn--lg" target="_blank" rel="noopener" style="width: 100%; justify-content: center; text-decoration: none;">Professional Membership</a>
            </div>
        </div>
    </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);

    const modal = document.getElementById('acmMembershipModal');
    const closeBtn = document.getElementById('closeAcmModalBtn');

    closeBtn.addEventListener('click', () => {
        modal.style.display = 'none';
    });
    
    window.addEventListener('click', (e) => {
        if(e.target === modal) {
            modal.style.display = 'none';
        }
    });

    modal.querySelectorAll('a').forEach(a => {
        a.addEventListener('click', () => {
            modal.style.display = 'none';
        });
    });

    const links = document.querySelectorAll('a');
    links.forEach(link => {
        if (link.href.includes("proflevel_control.cfm") && !modal.contains(link)) {
            link.addEventListener('click', (e) => {
                e.preventDefault();
                modal.style.display = 'flex';
            });
        }
    });
});
