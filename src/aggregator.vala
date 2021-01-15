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
        public delegate bool PipelineDelegate(AggregationPipeline pipeline);

        private Gee.Map<string, Value?> _attributes = new Gee.HashMap<string, Value?>();
        private Gee.Map<string, Gee.List<Value?>> _list_attributes = new Gee.HashMap<string, Gee.List<Value?>>();
        
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

        public AggregationPipeline set_list_attribute(string name, Value? value) {
            return set_list_attribute_at_index(name, value, 0);
        }

        public AggregationPipeline set_list_attribute_at_index(string name, Value? value, int index) {
            var list = _list_attributes.get(name);
            if (list == null) {
                list = new Gee.ArrayList<Value?>();
                _list_attributes.set(name, list);
            }
            list.insert(index, value);
            return this;
        }

        public Gee.List<Value?>? get_list_attribute(string name) {
            return _list_attributes.get(name);
        }

        public bool has_attribute(string name) {
            return _attributes.has_key(name) || _list_attributes.has_key(name);
        }

        public void commit(AggregationPredicate aggregation_predicate, PipelineDelegate pipeline_delegate) {
            if (!aggregation_predicate.should_commit(this)) {
                return;
            }
            if (pipeline_delegate(this)) {
                pipeline_commit(id);
                _attributes.clear();
                _list_attributes.clear();
            }
        }
    }
}