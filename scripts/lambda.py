import json
import urllib.request

def lambda_handler(event, context):
    url = "https://api.openbrewerydb.org/v1/breweries?by_city=Columbus&by_state=Ohio"
    
    try:
        with urllib.request.urlopen(url) as response:
            breweries = json.loads(response.read())
        
        formatted_breweries = []
        for brewery in breweries:
            formatted_breweries.append({
                "name": brewery.get("name", ""),
                "street": brewery.get("street", ""),
                "phone": brewery.get("phone", "")
            })
        
        formatted_breweries.sort(key=lambda x: x["name"])
        
        for brewery in formatted_breweries:
            print(json.dumps(brewery))
        
        return {
            "statusCode": 200,
            "body": json.dumps({"message": "Breweries logged successfully"})
        }
    except Exception as e:
        print(f"Error: {str(e)}")
        return {
            "statusCode": 500,
            "body": json.dumps({"error": str(e)})
        }