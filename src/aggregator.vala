using eip.patterns;

namespace eip.patterns {

    public class Aggregator {
        
        private Gee.Map<string, AggregationPipeline?> _pipelines = new Gee.HashMap<string, AggregationPipeline?>();
        private static Aggregator _instance;

        private Aggregator() {}

        public static Aggregator get_instance() {
            if (_instance == null) {
                _instance = new Aggregator();
            }
            return _instance;
        }

        public AggregationPipeline new_aggregation_pipeline(string id) {
            var new_pipeline = new AggregationPipeline(id);
            new_pipeline.pipeline_commit.connect(commit_pipeline); 
            _pipelines.set(id, new_pipeline);
            return new_pipeline;
        }

        private void commit_pipeline(string id) {
            _pipelines.unset(id);
        }

        public AggregationPipeline find_aggregation_pipeline(string id) {
            return _pipelines.get(id);
        }
    }

    public interface AggregationPredicate : Object {

        public abstract bool should_commit(AggregationPipeline aggregation_pipeline);
    }

    public class AggregationPipeline : Object {

        public signal void pipeline_commit(string id);
        public delegate void PipelineDelegate(AggregationPipeline pipeline);

        private Gee.Map<string, Value?> _attributes = new Gee.HashMap<string, Value?>();
        public string id { 
            public get; 
            construct set; 
        }

        public AggregationPipeline(string id) {
            Object(id: id);
        }

        public AggregationPipeline set_attribute(string name, Value? value) {
            _attributes.set(name, value);
            return this;
        }

        public Value? get_attribute(string name) {
            return _attributes.get(name);
        }

        public bool has_attribute(string name) {
            return _attributes.has_key(name);
        }

        public void commit(AggregationPredicate aggregation_predicate, PipelineDelegate pipeline_delegate) {
            if (!aggregation_predicate.should_commit(this)) {
                return;
            }
            pipeline_delegate(this);
            pipeline_commit(id);
            _attributes.clear();
        }

        public void dump() {
            _attributes.entries.foreach(entry => {
                print("%s = %s \n", entry.key, entry.value.strdup_contents());
                return true;
            });
        }
    }
}

private class TestPredicate : AggregationPredicate, Object {

    public bool should_commit(AggregationPipeline pipeline) {
        return pipeline.has_attribute("attr1") && pipeline.has_attribute("attr2") && pipeline.has_attribute("attr3");
    }
}

//  public static int main(string[] args) {
//      var aggregator = Aggregator.get_instance();
//      var pipeline = aggregator.new_aggregation_pipeline("test", new TestPredicate());
//      pipeline.commit_pipeline.connect(commited => {
//          print("Committing pipeline!\n");
//          commited.dump();
//      });
    
//      pipeline.set_attribute("attr1", 123);
//      pipeline.set_attribute("attr2", "bleble");

//      return 0;
//  }

