import Foundation

/// Coach tips shown under each drill: how to do it well and what helps most.
enum Tips {
    static func forDrill(_ id: String) -> [String] { all[id] ?? [] }

    private static let wallCatches = [
        "Make a \"W\" with your thumbs nearly touching behind the ball, fingers spread and relaxed.",
        "Catch out in front of your body with elbows slightly bent, then bring the ball in to soften it.",
        "Watch the ball all the way into your hands. Most drops come from looking away early.",
        "Throw at the same spot on the wall so each rep is the same, then speed up.",
    ]

    private static let all: [String: [String]] = [
        // Warm-up
        "w1": [
            "Start easy and build up. You should be warm and breathing a little harder, not tired.",
            "High knees: stay tall and land on the balls of your feet.",
            "Butt kicks: keep your knees pointing down and flick your heels up quickly.",
        ],
        "w2": [
            "Hold a wall or chair so you can swing freely without wobbling.",
            "Swing from the hip with a relaxed leg. Start small and let it get bigger each rep.",
            "Keep your chest up and don't let your lower back arch on the back swing.",
        ],
        "w3": [
            "Squats: sit back and down, knees following your toes, heels flat on the floor.",
            "Lunges: take a long step, drop the back knee towards the floor, then turn your chest over the front leg.",
            "Go slowly here. This is where you find tight spots before the real work.",
        ],
        "w4": [
            "Knees bent, weight on the balls of your feet, hands out in front like you're about to save.",
            "Bounces are tiny and quick. Your heels barely leave the floor.",
            "Keep your head still and eyes forward, as if watching a striker.",
        ],

        // Day A
        "a1": [
            "Small, quick steps on the balls of your feet. Quiet feet are fast feet.",
            "Pump your arms. Fast arms make fast feet.",
            "Look ahead, not down. Glance at the tape, then trust your feet.",
            "Get it clean first. If you clip the tape, slow down.",
        ],
        "a2": [
            "Stay low with knees bent the whole way along.",
            "Say the rhythm in your head: in, in, out, out.",
            "Keep your hips facing forward. Only your feet move sideways.",
            "Lead with the other foot on the way back so both sides get equal work.",
        ],
        "a3": [
            "Push off the back foot instead of reaching with the front one.",
            "Feet never cross and never click together. Keep them about shoulder-width apart.",
            "Stop dead in your set position: balanced, hands ready, weight forward.",
            "Keep your head at the same height. No bobbing up and down.",
        ],
        "a4": [
            "Go down in order: side of the knee, hip, then shoulder. Never straight onto your elbow.",
            "Keep your hands in front of your face as you go down, as if holding a ball.",
            "Get up fast by pushing with your top hand and swinging your top leg through.",
            "Use pillows or a mattress every time. No hard floors.",
        ],
        "a5": [
            "Open your hips and step back at 45 degrees. Don't backpedal in a straight line.",
            "Stay low and keep your eyes forward, where the ball would be.",
            "Push hard off the back foot to return to your start spot.",
            "Finish every rep balanced in your set position.",
        ],
        "a6": [
            "Small, fast hops. Just clear the line.",
            "Land softly on the balls of your feet with knees slightly bent.",
            "Keep your feet together and your chest up.",
            "If your landings get loud, slow down or stop early.",
        ],

        // Day B
        "b1": wallCatches,
        "x-catches": wallCatches,
        "x-hands10": [
            "Pick two or three drills and rotate so your hands keep working.",
            "Keep the quality high. A clean catch beats a fast, sloppy one.",
            "Finish with your weaker hand so it gets extra reps.",
        ],
        "b1w": [
            "Throw a little softer and stand a little closer than you do with two hands.",
            "Spread your fingers wide and give with the ball as it arrives.",
            "Keep your other hand ready behind it as a backup.",
            "This is the one that makes the difference. Expect drops and keep going.",
        ],
        "b2": [
            "Throw, then a small hop so you land in your set position just before the ball arrives.",
            "Land balanced: feet shoulder-width apart, knees bent, weight forward.",
            "Hands out in front and ready before the ball gets to you.",
            "This is the timing you use just as a striker shoots, so make each one sharp.",
        ],
        "b3": [
            "Turn your head first to find the ball, then let your body follow.",
            "Turn on the balls of your feet with small quick steps.",
            "Get your hands up early in the \"W\" shape.",
            "Start with an easy throw and let it bounce. Make it harder as you improve.",
        ],
        "b4": [
            "Stay low on your toes so you can move either way.",
            "Watch the ball, not the wall.",
            "Take small adjusting steps and reach with both hands when you can.",
            "It is meant to be awkward. Reacting to the odd bounce is the whole point.",
        ],
        "b5": [
            "Start with one ball until the rhythm is steady, then add the second.",
            "Throw one just as the other reaches the wall.",
            "Keep throws at chest height and the same strength every time.",
            "Soft hands. Catch, don't slap.",
        ],
        "b6": [
            "Get your body behind the ball so there is no gap between your knee and your other foot.",
            "Little fingers together, palms open and facing the ball.",
            "Scoop it up and hug it into your chest.",
            "Keep your head over the ball and watch it into your hands.",
        ],
        "b7": [
            "Start on your knees, sitting tall, with the ball held in front.",
            "Fall sideways and land on the side of your thigh, hip and shoulder. Not your elbow or stomach.",
            "Top hand goes behind the ball, bottom hand underneath, and the ball touches the mattress first.",
            "Push slightly forward as you fall, not straight sideways or backwards.",
        ],

        // Day C: explosive
        "c1": [
            "Sit back, swing your arms and jump straight up.",
            "Land toes first, then heels, bending your knees to soak it up.",
            "Knees stay in line with your toes. Don't let them cave in.",
            "Pause and reset between jumps. Each one should be your best.",
        ],
        "c2": [
            "Push sideways off the outside leg and land softly on the other.",
            "Stick the landing: hold for a full second without wobbling.",
            "The landing knee stays over your toes, hips back, chest up.",
            "Start with short jumps. Go further only when you can hold every landing.",
        ],
        "c3": [
            "Keep your body upright and switch legs in the air.",
            "Land softly in a lunge with the front knee over your ankle.",
            "Use your arms to help you up and to balance.",
            "If your knees wobble, take the jump out and do slow lunges instead.",
        ],
        "c4": [
            "Jump high first, then pull your knees up. Don't bend down to meet them.",
            "Land softly and reset before the next one.",
            "Keep your chest up the whole time.",
            "These are hard. Stop the set as soon as a landing gets loud or messy.",
        ],

        // Day C: strength
        "s1": [
            "Hold the weight tight against your chest with elbows pointing down.",
            "Feet a bit wider than your shoulders, toes turned slightly out.",
            "Sit down between your heels with your chest up and knees following your toes.",
            "Keep your heels flat and push the floor away to stand up.",
            "Go lighter and deeper before you go heavier.",
        ],
        "s2": [
            "Stand far enough from the bed that your front shin stays almost vertical at the bottom.",
            "Go straight down. Most of your weight is on the front foot.",
            "Front knee follows your toes and doesn't cave in.",
            "Lean your chest forward slightly and hold something for balance at first.",
        ],
        "s3": [
            "Keep a soft bend in your standing knee.",
            "Push your hips back and let your chest and back leg tip like a seesaw.",
            "Flat back, with your hips square to the floor.",
            "Go slowly. Touch a wall with one finger for balance if you need it.",
        ],
        "s4": [
            "Hands just wider than your shoulders, body in one straight line from head to heels.",
            "Squeeze your stomach and glutes so your hips don't sag.",
            "Lower your chest to just above the floor with elbows at about 45 degrees.",
            "Too hard? Put your hands on the bed or drop to your knees and keep the straight line.",
        ],
        "s5": [
            "Hinge forward with a flat back, or rest one hand on the bed.",
            "Pull your elbow back towards your hip, not up to your shoulder.",
            "Squeeze your shoulder blade at the top, then lower slowly.",
            "Keep your shoulders level. No twisting to lift the weight.",
        ],
        "s6": [
            "Elbow right under your shoulder.",
            "Lift your hips so your body is one straight line. Don't let them drop.",
            "Squeeze your glutes and breathe steadily.",
            "Too hard? Bend your knees and hold from your knees instead.",
        ],
        "s7": [
            "Press your lower back into the floor and keep it there the whole time.",
            "Lower the opposite arm and leg slowly, then bring them back.",
            "Only go as low as you can without your back lifting.",
            "Breathe out as you reach.",
        ],
    ]
}
