import 'package:checked_yaml/checked_yaml.dart';

import 'codelab.dart';
import 'fetcher.dart';
import 'meta.dart';
import 'step.dart';

abstract class CodelabFetcherImpl implements CodelabFetcher {
  Future<String> loadFileContents(List<String> relativePath);

  @override
  Future<Codelab> getCodelab() async {
    var metadata = await fetchMeta();
    var steps = await fetchSteps(metadata);
    return Codelab('Example codelab', metadata.type, steps);
  }

  Future<Meta> fetchMeta() async {
    var contents = await loadFileContents(['meta.yaml']);
    return checkedYamlDecode(contents, (Map m) => Meta.fromJson(m));
  }

  Future<List<Step>> fetchSteps(Meta metadata) async {
    var steps = <Step>[];
    for (var stepConfig in metadata.steps) {
      steps.add(await fetchStep(stepConfig));
    }
    return steps;
  }

  Future<Step> fetchStep(StepConfiguration config) async {
    var directory = config.directory;
    var instructions = await loadFileContents([directory, 'instructions.md']);
    var snippet = await loadFileContents([directory, 'snippet.dart']);
    var solution = config.hasSolution
        ? await loadFileContents([directory, 'solution.dart'])
        : null;
    return Step(config.name, instructions, snippet, solution: solution);
  }
}
