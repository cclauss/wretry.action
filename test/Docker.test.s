( function _Docker_test_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( 'wTools' );
  _.include( 'wTesting' );
  _.include( 'wPathBasic' );
}

const _ = _global_.wTools;
const __ = _globals_.testing.wTools;
const docker = require( '../src/Docker.js' );

// --
// context
// --

function onSuiteBegin()
{
  let context = this;
  context.assetsOriginalPath = __.path.join( __dirname, '_asset' );
  context.suiteTempPath = __.path.tempOpen( __.path.join( __dirname, '../..' ), 'Docker' );
}

//

function onSuiteEnd()
{
  let context = this;
  _.assert( _.str.has( context.suiteTempPath, '/Docker-' ) )
  __.path.tempClose( context.suiteTempPath );
}

// --
// test
// --

function exists( test )
{
  if( !_.process.insideTestContainer() )
  return test.true( true );

  const ubuntuIs = _.str.begins( process.env.ImageOS, 'ubuntu' );
  const windowsLatestIs = process.env.ImageOS === 'win22';

  /* - */

  test.case = 'docker exists on ubuntu-latest and windows-latest';
  var got = docker.exists();
  if( ubuntuIs || windowsLatestIs )
  test.identical( got, true );
  else
  test.identical( got, false );
}

//

function imageBuild( test )
{
  if( !_.process.insideTestContainer() )
  return test.true( true );

  const a = test.assetFor( 'image' );
  a.reflect();

  const ubuntuIs = _.str.begins( process.env.ImageOS, 'ubuntu' );
  const windowsLatestIs = process.env.ImageOS === 'win22';

  if( !ubuntuIs )
  return test.shouldThrowErrorSync( () => docker.imageBuild( a.routinePath, 'Dockerfile' ) );

  /* - */

  test.case = 'build an image';
  var got = docker.imageBuild( a.routinePath, 'Dockerfile' );
  test.identical( got, 'imagebuild_repo:imagebuild_tag' );

  /* - */

  if( !Config.debug )
  return;

  var onResolve = ( err, arg ) =>
  {
    test.identical( arg, undefined );
    test.true( _.error.is( err ) );
    var msg = 'The action does not support requested Docker image type "wrong:image". Please, open an issue with the request for the feature.';
    test.identical( err.originalMessage, msg );
  };
  test.shouldThrowErrorSync( () => docker.imageBuild( a.routinePath, 'wrong:image' ), onResolve );
}

//

function runCommandForm( test )
{
  const a = test.assetFor( false );
  const workspacePath = a.path.nativize( a.abs( '.' ) );
  process.env.GITHUB_WORKSPACE = workspacePath;
  process.env.INPUT_ENV_CONTEXT = '{}';

  /* - */

  test.case = 'empty inputs options';
  var got = docker.runCommandForm( 'repo:tag', {} );
  var exp =
`docker run --name tag --label repo --workdir /github/workspace --rm -e HOME -e GITHUB_JOB -e GITHUB_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER -e GITHUB_RUN_ID -e GITHUB_RUN_NUMBER -e GITHUB_RETENTION_DAYS -e GITHUB_RUN_ATTEMPT -e GITHUB_ACTOR -e GITHUB_WORKFLOW -e GITHUB_HEAD_REF -e GITHUB_BASE_REF -e GITHUB_EVENT_NAME -e GITHUB_SERVER_URL -e GITHUB_API_URL -e GITHUB_GRAPHQL_URL -e GITHUB_REF_NAME -e GITHUB_REF_PROTECTED -e GITHUB_REF_TYPE -e GITHUB_WORKSPACE -e GITHUB_ACTION -e GITHUB_EVENT_PATH -e GITHUB_ACTION_REPOSITORY -e GITHUB_ACTION_REF -e GITHUB_PATH -e GITHUB_ENV -e GITHUB_STEP_SUMMARY -e RUNNER_OS -e RUNNER_ARCH -e RUNNER_NAME -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" -v "/home/runner/work/_temp/_runner_file_commands":"/github/file_commands" -v "${ workspacePath }":"/github/workspace" repo:tag`;
  test.identical( got, exp );

  test.case = 'not empty inputs options';
  var got = docker.runCommandForm( 'repo:tag', { 'INPUT_STR' : 'str', 'INPUT_NUMBER' : '2' } );
  var exp =
`docker run --name tag --label repo --workdir /github/workspace --rm -e INPUT_STR -e INPUT_NUMBER -e HOME -e GITHUB_JOB -e GITHUB_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER -e GITHUB_RUN_ID -e GITHUB_RUN_NUMBER -e GITHUB_RETENTION_DAYS -e GITHUB_RUN_ATTEMPT -e GITHUB_ACTOR -e GITHUB_WORKFLOW -e GITHUB_HEAD_REF -e GITHUB_BASE_REF -e GITHUB_EVENT_NAME -e GITHUB_SERVER_URL -e GITHUB_API_URL -e GITHUB_GRAPHQL_URL -e GITHUB_REF_NAME -e GITHUB_REF_PROTECTED -e GITHUB_REF_TYPE -e GITHUB_WORKSPACE -e GITHUB_ACTION -e GITHUB_EVENT_PATH -e GITHUB_ACTION_REPOSITORY -e GITHUB_ACTION_REF -e GITHUB_PATH -e GITHUB_ENV -e GITHUB_STEP_SUMMARY -e RUNNER_OS -e RUNNER_ARCH -e RUNNER_NAME -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" -v "/home/runner/work/_temp/_runner_file_commands":"/github/file_commands" -v "${ workspacePath }":"/github/workspace" repo:tag`;
  test.identical( got, exp );

  test.case = 'not empty inputs options, env context';
  process.env.INPUT_ENV_CONTEXT = '{"FOO": "bar"}';
  var got = docker.runCommandForm( 'repo:tag', { 'INPUT_STR' : 'str', 'INPUT_NUMBER' : '2' } );
  var exp =
`docker run --name tag --label repo --workdir /github/workspace --rm -e FOO -e INPUT_STR -e INPUT_NUMBER -e HOME -e GITHUB_JOB -e GITHUB_REF -e GITHUB_SHA -e GITHUB_REPOSITORY -e GITHUB_REPOSITORY_OWNER -e GITHUB_RUN_ID -e GITHUB_RUN_NUMBER -e GITHUB_RETENTION_DAYS -e GITHUB_RUN_ATTEMPT -e GITHUB_ACTOR -e GITHUB_WORKFLOW -e GITHUB_HEAD_REF -e GITHUB_BASE_REF -e GITHUB_EVENT_NAME -e GITHUB_SERVER_URL -e GITHUB_API_URL -e GITHUB_GRAPHQL_URL -e GITHUB_REF_NAME -e GITHUB_REF_PROTECTED -e GITHUB_REF_TYPE -e GITHUB_WORKSPACE -e GITHUB_ACTION -e GITHUB_EVENT_PATH -e GITHUB_ACTION_REPOSITORY -e GITHUB_ACTION_REF -e GITHUB_PATH -e GITHUB_ENV -e GITHUB_STEP_SUMMARY -e RUNNER_OS -e RUNNER_ARCH -e RUNNER_NAME -e RUNNER_TOOL_CACHE -e RUNNER_TEMP -e RUNNER_WORKSPACE -e ACTIONS_RUNTIME_URL -e ACTIONS_RUNTIME_TOKEN -e ACTIONS_CACHE_URL -e GITHUB_ACTIONS=true -e CI=true -v "/var/run/docker.sock":"/var/run/docker.sock" -v "/home/runner/work/_temp/_github_home":"/github/home" -v "/home/runner/work/_temp/_github_workflow":"/github/workflow" -v "/home/runner/work/_temp/_runner_file_commands":"/github/file_commands" -v "${ workspacePath }":"/github/workspace" repo:tag`;
  test.identical( got, exp );

  /* - */

  if( !Config.debug )
  return;

  test.case = 'invalid image name format';
  test.shouldThrowErrorSync( () => docker.runCommandForm( 'repo', {} ) );

  test.case = 'empty tag name';
  test.shouldThrowErrorSync( () => docker.runCommandForm( 'repo:', {} ) );

  test.case = 'empty repo name';
  test.shouldThrowErrorSync( () => docker.runCommandForm( ':tag', {} ) );
}

// --
// declare
// --

const Proto =
{
  name : 'Docker',
  silencing : 1,

  onSuiteBegin,
  onSuiteEnd,

  context :
  {
    assetsOriginalPath : null,
    suiteTempPath : null,
  },

  tests :
  {
    exists,
    imageBuild,
    runCommandForm,
  },
};

//

const Self = wTestSuite( Proto );
if( typeof module !== 'undefined' && !module.parent )
wTester.test( Self.name );

})();

