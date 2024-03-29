import 'package:alice_store/models/project_feed_model.dart';
import 'package:alice_store/services/api/api_service.dart';
import 'package:alice_store/utils/constants.dart';
import 'dart:developer' as dev;

class ProjectFeedService{
  final ApiService _apiService = ApiService();

  Future<List<ProjectFeedModel>> fetchProjectFeeds() async{
    List<ProjectFeedModel> projectFeeds= [];
    dynamic response = await _apiService.getResponse(Constants.apiEndPoints.projectFeedsEndPoint);
    if (response != null) {
      projectFeeds = ProjectFeedModel.projectFeedModelFromJson(response);
    }
    //dev.log('PROJECT FEED :$projectFeeds');
    return projectFeeds;
  }
}