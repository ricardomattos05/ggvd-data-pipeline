from src.bronze.source.table.lambda_function import lambda_handler


def test_lambda_handler():
    event = {}
    context = {}
    result = lambda_handler(event, context)
    assert result == {"message": "Hello, world!"}
