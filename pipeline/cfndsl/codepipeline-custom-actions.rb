CloudFormation do
  Description("Dromedary CodePipeline Custom Action Provisioning")
  AWSTemplateFormatVersion("2010-09-09")

  Parameter("MyInputArtifacts") do
    Type("String")
    Default("DromedarySource")
  end

  Parameter("MyBuildProvider") do
    Type("String")
  end

  Parameter("MyJenkinsURL") do
    Type("String")
  end

  Resource("MyCustomBuildActionType") do
    Type("AWS::CodePipeline::CustomActionType")
    Property("Category", "Build")
    Property("Provider", Ref("MyBuildProvider"))
    Property("Version", "1")
    Property("ConfigurationProperties", [
      {
        "Description" => "The name of the build project must be provided when this action is added to the pipeline.",
        "Key"         => "true",
        "Name"        => "ProjectName",
        "Queryable"   => "true",
        "Required"    => "true",
        "Secret"      => "false",
        "Type"        => "String"
      }
    ])
    Property("InputArtifactDetails", {
      "MaximumCount" => "5",
      "MinimumCount" => "1"
    })
    Property("OutputArtifactDetails", {
      "MaximumCount" => "5",
      "MinimumCount" => "0"
    })
    Property("Settings", {
      "EntityUrlTemplate"    => FnJoin("", [
        Ref("MyJenkinsURL"),
        "job/{Config:ProjectName}"
      ]),
      "ExecutionUrlTemplate" => FnJoin("", [
        Ref("MyJenkinsURL"),
        "job/{Config:ProjectName}/{ExternalExecutionId}"
      ])
    })
  end

  Resource("MyCustomTestActionType") do
    Type("AWS::CodePipeline::CustomActionType")
    Property("Category", "Test")
    Property("Provider", Ref("MyBuildProvider"))
    Property("Version", "1")
    Property("ConfigurationProperties", [
      {
        "Description" => "The name of the build project must be provided when this action is added to the pipeline.",
        "Key"         => "true",
        "Name"        => "ProjectName",
        "Queryable"   => "true",
        "Required"    => "true",
        "Secret"      => "false",
        "Type"        => "String"
      }
    ])
  Property("InputArtifactDetails", {
    "MaximumCount" => "5",
    "MinimumCount" => "1"
  })
  Property("OutputArtifactDetails", {
    "MaximumCount" => "5",
    "MinimumCount" => "0"
  })
  Property("Settings", {
    "EntityUrlTemplate"    => FnJoin("", [
      Ref("MyJenkinsURL"),
      "job/{Config:ProjectName}"
    ]),
    "ExecutionUrlTemplate" => FnJoin("", [
      Ref("MyJenkinsURL"),
      "job/{Config:ProjectName}/{ExternalExecutionId}"
    ])
  })
  end

  Output("StackName") do
    Value(Ref("AWS::StackName"))
  end

  Output("CustomActionBuildName") do
    Description("CodePipeline Build Custom action name")
    Value(Ref("MyCustomBuildActionType"))
  end

  Output("CustomActionTestName") do
    Description("CodePipeline Test Custom action name")
    Value(Ref("MyCustomTestActionType"))
  end
end
