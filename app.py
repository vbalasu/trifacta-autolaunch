from chalice import Chalice
app = Chalice(app_name='trifacta-autolaunch')

# BEGIN Cloudformation Custom Resource (crhelper)
from crhelper import CfnResource
import json
helper = CfnResource()
@helper.create
@helper.update
def do_autolaunch(event, context):
    helper.Data['No1'] = event['ResourceProperties']['No1']
@helper.delete
def no_op(_, __):
    pass
@app.lambda_function(name='TrifactaAutolaunchLambda')
def trifacta_autolaunch(event, context):
    import boto3
    cf = boto3.client('cloudformation')
    describe_stacks = cf.describe_stacks(StackName=event['StackId'])
    describe_stack_resources = cf.describe_stack_resources(StackName=event['StackId'])
    print('event', json.dumps(event, default=str))
    print('describe_stacks', json.dumps(describe_stacks, default=str))
    print('describe_stack_resources', json.dumps(describe_stack_resources, default=str))
    helper(event, context)
    return helper.Data
# END Cloudformation Custom Resource (crhelper)

@app.route('/')
def index():
    return {'hello': 'world'}


# The view function above will return {"hello": "world"}
# whenever you make an HTTP GET request to '/'.
#
# Here are a few more examples:
#
# @app.route('/hello/{name}')
# def hello_name(name):
#    # '/hello/james' -> {"hello": "james"}
#    return {'hello': name}
#
# @app.route('/users', methods=['POST'])
# def create_user():
#     # This is the JSON body the user sent in their POST request.
#     user_as_json = app.current_request.json_body
#     # We'll echo the json body back to the user in a 'user' key.
#     return {'user': user_as_json}
#
# See the README documentation for more examples.
#
