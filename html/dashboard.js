document.getElementById('startJob').addEventListener('click', function() {
    const action = this.dataset.action || 'startJob';
    fetch(`https://${GetParentResourceName()}/${action}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    });
});

function formatNumber(number) {
    return new Intl.NumberFormat('en-US').format(number);
}

window.addEventListener('message', function(event) {
    if (event.data.type === 'toggleDashboard') {
        const dashboard = document.querySelector('.dashboard');
        dashboard.style.display = event.data.show ? 'block' : 'none';
    } else if (event.data.type === 'updateButton') {
        const startButton = document.getElementById('startJob');
        startButton.textContent = event.data.buttonText;
        startButton.dataset.action = event.data.action;
    } else if (event.data.type === 'updateDashboard') {
        document.getElementById('level').textContent = event.data.level || 1;
        document.getElementById('xp').textContent = 
            `${event.data.experience || 0}/${event.data.required || 100}`;
        
        const progressFill = document.getElementById('progressFill');
        progressFill.style.width = '0%';
        
        setTimeout(() => {
            progressFill.style.width = `${event.data.progress || 0}%`;
        }, 100);

        document.getElementById('totalJobs').textContent = event.data.total_jobs || 0;
        document.getElementById('totalEarnings').textContent = `$${formatNumber(event.data.total_earnings || 0)}`;

        const jobList = document.getElementById('jobList');
        if (event.data.recentJobs && event.data.recentJobs.length > 0) {
            jobList.innerHTML = event.data.recentJobs.map(job => {
                let statusClass = '';
                let statusText = '';
                
                switch(job.status) {
                    case 'completed':
                        statusClass = 'completed';
                        statusText = 'Completed';
                        break;
                    case 'failed':
                        statusClass = 'failed';
                        statusText = 'Failed';
                        break;
                    case 'ongoing':
                        statusClass = 'ongoing';
                        statusText = 'In Progress';
                        break;
                }
                
                return `
                    <li class="job-item ${statusClass}">
                        <div class="job-status">${statusText} - ${job.date}</div>
                        <div class="job-progress">Spots Cleaned: ${job.spots_cleaned || 0}/${job.total_spots || 0}</div>
                    </li>
                `;
            }).join('');
        } else {
            jobList.innerHTML = '<li class="job-item">No recent jobs</li>';
        }

        const payoutList = document.getElementById('payoutList');
        if (event.data.recentJobs && event.data.recentJobs.length > 0) {
            const completedJobs = event.data.recentJobs.filter(job => job.status === 'completed');
            payoutList.innerHTML = completedJobs.length > 0 
                ? completedJobs.map(job => `
                    <li class="payout-item">
                        <div class="payout-date">${job.date}</div>
                        <div class="payout-amount">$${job.payout}</div>
                    </li>
                `).join('')
                : '<li class="payout-item">No completed jobs</li>';
        }
    }
});

document.getElementById('closeButton').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeDashboard`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        }
    });
});