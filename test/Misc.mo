import JSON "../src/JSON";

switch (JSON.parse("1.1")) {
    case (?#Float _) {};
    case _ {
        assert(false);
    };
};

switch (JSON.parse("1e10")) {
    case (?#Float _) {};
    case _ {
        assert(false);
    };
};

switch (JSON.parse("11")) {
    case (?#Number _) {};
    case _ {
        assert(false);
    };
};

switch (JSON.parse("{\"address\": \"0xf321940f3d1599a1336ca33f08015db52edb0a14\", \"score\": \"7.375268\", \"status\": \"DONE\", \"last_score_timestamp\": \"2024-02-09T15:26:47.812648+00:00\", \"evidence\": null, \"error\": null, \"stamp_scores\": {\"githubAccountCreationGte#90\": 1.020878, \"githubAccountCreationGte#180\": 1.230878, \"githubAccountCreationGte#365\": 1.430878, \"githubContributionActivityGte#120\": 1.230878, \"githubContributionActivityGte#30\": 1.230878, \"githubContributionActivityGte#60\": 1.230878}}")) {
    case (?_) {};
    case _ {
        assert(false);
    };
};
