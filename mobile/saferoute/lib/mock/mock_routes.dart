const String mockRouteResponseJson = r'''
[
   {
        "route": {
            "polyline": "imanAceiyM]A@]Bg@L{BJUBg@LiEB}AN{D@kAGW?g@?{@@oD?_B^A?aBCsFL??G?e@C{Bn@?rCI`CDp@?RVVNLFPF\\Bd@A^AFBJMR@BCJDHWLa@NGNALC@T",
            "distance_km": 1.43,
            "duration_min": 19,
            "safety_score": 59,
            "risk_level": "MEDIUM",
            "explanations": {
                "activity": "High likelihood of human activity",
                "crowd": "Some people likely present",
                "lighting": "Moderately lit areas",
                "road_type": "Mostly residential roads",
                "time_of_day": "Day & evening travel has less risk"
            }
        },
        "segments": [
            {
                "coordinate": {
                    "lat": 12.95589,
                    "lng": 77.71234
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 100,
                "segment_safety_score": 76
            },
            {
                "coordinate": {
                    "lat": 12.95572,
                    "lng": 77.71705
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 80,
                "segment_safety_score": 70
            },
            {
                "coordinate": {
                    "lat": 12.95454,
                    "lng": 77.72103
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 55,
                "activity_likelihood_score": 100,
                "segment_safety_score": 73
            },
            {
                "coordinate": {
                    "lat": 12.95212,
                    "lng": 77.721
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 8,
                "segment_safety_score": 48
            }
        ]
    },
    {
        "route": {
            "polyline": "imanAceiyM]A@]Bg@L{BJUBg@LiEB}AN{D@kAGW?g@?{@?k@?It@CZCvBEnCIhCIx@AhCBxA@RACa@?kAAi@Gq@@kB?yB?g@IGeCD_@@FYDk@@WI_@CODMDMT?HKHWLa@NGNALC@T",
            "distance_km": 1.568,
            "duration_min": 21,
            "safety_score": 58,
            "risk_level": "MEDIUM",
            "explanations": {
                "activity": "Moderate likelihood of human activity",
                "crowd": "Some people likely present",
                "lighting": "Moderately lit areas",
                "road_type": "Mostly main roads",
                "time_of_day": "Day & evening travel has less risk"
            }
        },
        "segments": [
            {
                "coordinate": {
                    "lat": 12.95589,
                    "lng": 77.71234
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 100,
                "segment_safety_score": 76
            },
            {
                "coordinate": {
                    "lat": 12.95572,
                    "lng": 77.71705
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 80,
                "segment_safety_score": 70
            },
            {
                "coordinate": {
                    "lat": 12.95179,
                    "lng": 77.71803
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 73,
                "segment_safety_score": 67
            },
            {
                "coordinate": {
                    "lat": 12.95212,
                    "lng": 77.721
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 8,
                "segment_safety_score": 48
            }
        ]
    },
    {
        "route": {
            "polyline": "imanAceiyM]A@]Bg@L{BJUBg@LiE?WR?hAGlCILIFILYdAIAMGaAGeAFODe@FEBiAFuC@[|@AjAGx@AhDBlA?EgA@e@Ai@Gq@?qA?aA@yBIGm@?aBDU?Jk@Bg@CQIg@JYT?HKHWLa@NGNALC@T",
            "distance_km": 1.559,
            "duration_min": 21,
            "safety_score": 55,
            "risk_level": "MEDIUM",
            "explanations": {
                "activity": "Moderate likelihood of human activity",
                "crowd": "Some people likely present",
                "lighting": "Moderately lit areas",
                "road_type": "Mostly main roads",
                "time_of_day": "Day & evening travel has less risk"
            }
        },
        "segments": [
            {
                "coordinate": {
                    "lat": 12.95589,
                    "lng": 77.71234
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 100,
                "segment_safety_score": 76
            },
            {
                "coordinate": {
                    "lat": 12.95413,
                    "lng": 77.71553
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 65,
                "activity_likelihood_score": 15,
                "segment_safety_score": 49
            },
            {
                "coordinate": {
                    "lat": 12.95179,
                    "lng": 77.71803
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 73,
                "segment_safety_score": 67
            },
            {
                "coordinate": {
                    "lat": 12.95212,
                    "lng": 77.721
                },
                "lighting_score": 50,
                "crowd_score": 50,
                "time_of_day_score": 100,
                "road_type_score": 80,
                "activity_likelihood_score": 8,
                "segment_safety_score": 48
            }
        ]
    }
]
''';
