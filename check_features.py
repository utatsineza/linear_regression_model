import joblib

model = joblib.load('best_yield_model.pkl')

if hasattr(model, 'feature_names_in_'):
    print("=== Model Features ===")
    features = list(model.feature_names_in_)
    for i, feature in enumerate(features, 1):
        print(f"{i}. {feature}")
    
    print("\n=== Full List ===")
    print(features)
else:
    print("No features stored")