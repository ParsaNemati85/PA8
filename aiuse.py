from reportlab.lib.pagesizes import letter
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import inch
from reportlab.lib import colors

doc = SimpleDocTemplate(
    "/mnt/user-data/outputs/AI_Usage_Summary_PA9_Khodabandehlou.pdf",
    pagesize=letter,
    leftMargin=1*inch, rightMargin=1*inch,
    topMargin=1*inch, bottomMargin=1*inch
)

styles = getSampleStyleSheet()
title_style = ParagraphStyle('Title2', parent=styles['Title'], fontSize=16, spaceAfter=6)
h1 = ParagraphStyle('H1', parent=styles['Heading1'], fontSize=13, spaceAfter=4, spaceBefore=14, textColor=colors.HexColor('#1a1a6e'))
h2 = ParagraphStyle('H2', parent=styles['Heading2'], fontSize=11, spaceAfter=3, spaceBefore=10, textColor=colors.HexColor('#2e2e8e'))
bullet = ParagraphStyle('Bullet', parent=styles['Normal'], fontSize=10, leftIndent=20, spaceAfter=4, leading=14)
normal = ParagraphStyle('Normal2', parent=styles['Normal'], fontSize=10, spaceAfter=4, leading=14)
code_style = ParagraphStyle('Code', parent=styles['Code'], fontSize=9, leftIndent=30, spaceAfter=3, textColor=colors.HexColor('#333333'))

story = []

story.append(Paragraph("PA9: Bouncing Ball — AI Usage Summary", title_style))
story.append(Paragraph("Parsa Khodabandehlou", normal))
story.append(Paragraph('GitHub Repository: <link href="https://github.com/ParsaNemati85/PA8" color="blue">https://github.com/ParsaNemati85/PA8</link>', normal))
story.append(Paragraph('All AI-generated pull requests are visible under the <b>Closed Pull Requests</b> tab of the repository.', normal))
story.append(Spacer(1, 0.15*inch))

story.append(Paragraph("Overview", h1))
story.append(Paragraph(
    "Two AI tools were used in this assignment: <b>OpenAI Codex</b> (via GitHub pull requests, "
    "linked above) and <b>Claude</b> (Anthropic). I provided the scaffolding — declaring variables, "
    "defining the general structure and desired plot behavior — and then had the AI fill in the "
    "implementation. Codex was responsible for the detailed PR-by-PR implementation work documented "
    "in the GitHub repository (see commit history for full detail on all edits; only the most "
    "significant changes are summarized here). "
    "Claude was used for conversational debugging, checking plot outputs against assignment criteria, "
    "and formatting this AI usage summary — the raw summary text (ai.txt, also on the GitHub) was "
    "provided to Claude, which reformatted it into this structured PDF. "
    "Several refactoring passes were required to remove approaches not covered in class "
    "or that Dr. Huesseni explicitly asked us to avoid from PA3 onwards (OOP, advanced video "
    "functions, spline/interpolation techniques).",
    normal))

story.append(Spacer(1, 0.1*inch))

# ---- PART 1 ----
story.append(Paragraph("Part 1 — PA9_KHODABANDEHLOU.m", h1))

story.append(Paragraph("Section 1: Frame Processing Loop (Lines 44–88)", h2))
items = [
    "Lines 44–88: AI wrote the for loop to read each frame with <font name='Courier'>read(vid, k)</font>, crop using index notation (e.g. <font name='Courier'>frameRGB(yCrop:yCropBot, xCrop:xCropBot, :)</font> instead of <font name='Courier'>imcrop</font>), apply RGB threshold, call <font name='Courier'>Centroid(BW)</font>, and store results.",
    "Lines 65–67: AI implemented the RGB threshold as a logical AND across all three channels — this approach was discussed in class.",
    "Lines 75–88: AI wrote the live subplot display: <font name='Courier'>imshow(BW)</font> on left, centroid trajectory with <font name='Courier'>plot</font> + 'X' marker on right, with <font name='Courier'>axis([...])</font> to fix axes and <font name='Courier'>pbaspect([cropW cropH 1])</font> to match aspect ratio. <b>pbaspect</b> was not taught in class — see explanation below.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

story.append(Paragraph("Pixel-to-Meter Conversion (Lines 91–95)", h2))
items = [
    "Lines 91–95: AI computed the equivalent ball diameter from thresholded area using <font name='Courier'>sqrt(4*ballAreaPx/pi)</font> and derived <font name='Courier'>px2m</font> from the median diameter across all valid frames. This avoids relying on any single frame.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

story.append(Paragraph("Section 2: Kinematics (Lines 98–138)", h2))
items = [
    "Lines 98–107: AI wrote the gap-filling logic using a <font name='Courier'>hasCentroid</font> logical mask and nearest-value fill for leading/trailing gaps. This replaced an earlier NaN/fillmissing approach that was removed during refactoring.",
    "Lines 110–112: AI wrote position correction (<font name='Courier'>yCorr = yPosM - yPosM(end)</font>) to set ground as zero, and applied <font name='Courier'>smooth(yCorr, 5)</font>. <b>smooth</b> was not taught in class — see explanation below.",
    "Lines 115–116: AI used <font name='Courier'>gradient(ySmooth, t)</font> for velocity and <font name='Courier'>gradient(yVel, t)</font> for acceleration. <b>gradient</b> computes central-difference numerical derivatives — discussed in class.",
    "Lines 119–138: AI wrote the three-subplot kinematics figure with labels, legend, and <font name='Courier'>yline(G, 'k--', 'g')</font> for the gravity reference line.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

story.append(Paragraph("Section 3: Bounce Heights and Coefficient of Restitution (Lines 141–165)", h2))
items = [
    "Lines 141–148: AI used <font name='Courier'>findpeaks(ySmooth, 'MinPeakDistance', ..., 'MinPeakProminence', ...)</font> to detect rebound maxima. <b>findpeaks</b> was not taught in class — see explanation below.",
    "Lines 151–153: AI prepended the initial drop height as bounce 0 using <font name='Courier'>hAll = [ySmooth(1); reboundHeights(:)]</font> and created the stem plot with <font name='Courier'>stem(bounceNumAll, hAll, 'filled', ...)</font>.",
    "Lines 156–162: AI computed per-bounce restitution as <font name='Courier'>eEach = sqrt(hAll(2:end) ./ hAll(1:end-1))</font> and averaged across quality bounces. The quality filter uses <font name='Courier'>minHeightFrac</font> defined in Declarations.",
    "Line 164: AI wrote <font name='Courier'>fprintf('Average coefficient of restitution: %.4f\\n', eMean)</font> to print e to the command window.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

story.append(Paragraph("Section 4: Energy (Lines 168–182)", h2))
items = [
    "Lines 168–170: AI wrote PE, KE, and TE using the formulas from the assignment theory section. <font name='Courier'>max(ySmooth, 0)</font> was added to prevent PE from going slightly negative due to smoothing near bounce points.",
    "Lines 172–182: AI wrote the single-axes energy plot with all three curves, legend, and axis labels.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

# ---- PART 2 ----
story.append(Paragraph("Part 2 — PA9P2_KHODABANDEHLOU.m", h1))
items = [
    "Lines 10–14: AI updated ball properties (<font name='Courier'>ballMass = 0.051</font>, <font name='Courier'>ballDm = 100e-3</font>) and video parameters (<font name='Courier'>frameRate = 120</font>, <font name='Courier'>frameStart/Stop</font>) for the custom video.",
    "Lines 17–20: AI updated RGB thresholds (<font name='Courier'>Cmin/Cmax</font>) for the new ball color. Threshold logic was inverted (<font name='Courier'>~(...)</font>) since the custom video had a dark background with a light ball.",
    "Lines 22–23: AI set <font name='Courier'>cropW</font> and <font name='Courier'>cropH</font> manually to match the video dimensions since no cropping was applied.",
    "Lines 44–55: AI added <font name='Courier'>firstCentCol</font> anchoring so the centroid trajectory x-axis starts at 0 at the first detected ball position, and updated <font name='Courier'>trajXLim</font> dynamically.",
    "All other sections (kinematics, bounce detection, energy) carried over from Part 1 with the updated Declarations values — no additional AI work was needed beyond parameter changes.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

# ---- REFACTORING ----
story.append(Paragraph("Refactoring Done After AI Output", h1))
story.append(Paragraph(
    "The following are the most notable refactoring changes. Additional smaller edits are visible in the full commit history on GitHub.",
    normal))
items = [
    "<b>Removed OOP:</b> AI initially used object-oriented patterns for frame handling. Removed per Dr. Huesseni's instruction from PA3 onwards.",
    "<b>Removed advanced video functions:</b> AI used <font name='Courier'>rgbvid</font> and NaN-based helpers not covered in class. Replaced with explicit logical masks (<font name='Courier'>hasCentroid</font>) and simple index-based frame reading.",
    "<b>Removed interpolation:</b> AI used <font name='Courier'>interp1</font> and spline techniques for the stem plot. Removed as interpolation is not covered in class.",
    "<b>Removed nan/isnan/fillmissing:</b> Replaced with zero-initialized vectors and the <font name='Courier'>hasCentroid</font> boolean mask.",
]
for item in items:
    story.append(Paragraph(f"• {item}", bullet))

# ---- OUT OF CLASS FUNCTIONS ----
story.append(Paragraph("Functions Not Taught in Class", h1))

funcs = [
    ("pbaspect([cropW cropH 1])", "Lines 84, 88 (P1); Line 55 (P2)",
     "Sets the plot box aspect ratio. Used to make the centroid trajectory plot match the pixel dimensions of the cropped video frame so the visual proportions are correct."),
    ("findpeaks(ySmooth, 'MinPeakDistance', ..., 'MinPeakProminence', ...)",
     "Lines 143–145 (P1); same section (P2)",
     "Finds local maxima in a signal. 'MinPeakDistance' prevents detecting two peaks within a minimum number of frames (avoids double-counting one bounce). 'MinPeakProminence' requires each peak to rise a minimum amount above surrounding data (filters out noise bumps). Used to detect rebound heights after each bounce."),
    ("smooth(y, 5)", "Line 112 (P1); same (P2)",
     "Applies a 5-point moving average to reduce jitter in the centroid position data before computing derivatives. Mentioned as an allowed method in the assignment spec."),
]

for fname, lines, explanation in funcs:
    story.append(Paragraph(f"<b><font name='Courier'>{fname}</font></b> — {lines}", normal))
    story.append(Paragraph(explanation, bullet))
    story.append(Spacer(1, 0.05*inch))

story.append(Spacer(1, 0.15*inch))
story.append(Paragraph("Summary", h1))
story.append(Paragraph(
    "AI played a significant role in this assignment. The majority of the implementation — "
    "including the frame processing loop, kinematics, bounce detection, coefficient of restitution "
    "calculation, and energy plots — was written by AI (Codex and Claude) based on scaffolding and "
    "direction provided by the student. Manual effort was focused on providing structure, verifying "
    "outputs against assignment requirements, and refactoring AI-generated code to conform to "
    "class standards. The full extent of AI contributions is documented in the GitHub commit history.",
    normal))

doc.build(story)
print("Done")